# Deploys Karpenter using Helm
resource "helm_release" "karpenter" {
  namespace  = "kube-system"
  name       = "karpenter"
  repository = "https://charts.karpenter.sh"
  chart      = "karpenter"
  version    = "0.16.3"
  wait       = true  # Ensures Helm waits for readiness

  values = [
    <<-EOT
    serviceAccount:
      name: ${var.service_account} # Attach the correct IAM service account
    settings:
      clusterName: ${var.cluster_name}
      clusterEndpoint: ${var.cluster_endpoint}
      interruptionQueue: ${var.queue_name}
    tolerations:
      - key: "CriticalAddonsOnly"
        operator: "Exists"
        effect: "NoSchedule"
    EOT
  ]
}

# Defines Karpenter EC2NodeClass for dynamic provisioning
resource "kubectl_manifest" "karpenter_node_class" {
  yaml_body = <<-YAML
    apiVersion: karpenter.k8s.aws/v1beta1
    kind: EC2NodeClass
    metadata:
      name: default
    spec:
      amiFamily: AL2023  # Uses Amazon Linux 2023 as the AMI family
      role: ${var.node_iam_role_name}  # Specifies the IAM role for Karpenter-managed nodes
      subnetSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${var.cluster_name}  # Selects subnets tagged for Karpenter
      securityGroupSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${var.cluster_name} # Selects security groups tagged for Karpenter
      tags:
        karpenter.sh/discovery: ${var.cluster_name} # Ensures node discovery by Karpenter
  YAML

  depends_on = [
    helm_release.karpenter   # Ensures Karpenter is installed before applying node class
  ]
}

# Karpenter Node Pool with x86 and Graviton Support
resource "kubectl_manifest" "karpenter_node_pool" {
  yaml_body = <<-YAML
    apiVersion: karpenter.sh/v1beta1
    kind: NodePool
    metadata:
      name: default
    spec:
      template:
        spec:
          nodeClassRef:    
            name: default   # References the previously defined EC2NodeClass
          requirements:
            - key: "karpenter.k8s.aws/instance-category"
              operator: In
              values: ["c", "m", "r"] # Allows compute, memory, and general-purpose instances
            - key: "karpenter.k8s.aws/instance-cpu"
              operator: In
              values: ["4", "8", "16", "32"]  # Supports different CPU configurations
            - key: "karpenter.k8s.aws/instance-architecture"
              operator: In
              values: ["amd64", "arm64"]  # Supports both x86 (amd64) and ARM (arm64) instances
            - key: "karpenter.k8s.aws/instance-generation"
              operator: Gt
              values: ["2"] # Ensures only newer-generation instances are selected
            - key: "karpenter.k8s.aws/capacity-type"
              operator: In
              values: ["spot"]  # Uses Spot instances for cost efficiency
            - key: "topology.kubernetes.io/zone"   # Multi-AZ support
              operator: In
              values: ${jsonencode(["${var.region}-a", "${var.region}-b", "${var.region}-c"])}
                      # Prevent Karpenter from scheduling CoreDNS
          taints:
            - key: "CriticalAddonsOnly"
              effect: "NoSchedule"
              operator: "Exists"
 # Limits the total CPU capacity provisioned by this NodePool
      limits:
        cpu: 1000  # Restricts the total CPU available to prevent over-scaling

      # Configures node consolidation to reduce costs by removing empty nodes
      disruption:
        consolidationPolicy: WWhenUnderutilized # Only consolidates when nodes are empty
        consolidateAfter: 60s # Waits 30 seconds before consolidating underutilized nodes
  YAML
  depends_on = [kubectl_manifest.karpenter_node_class]  # Ensures NodeClass is created before NodePool
}
