# Deploy Karpenter module using Terraform AWS EKS module
module "karpenter" {
  source = "terraform-aws-modules/eks/aws//modules/karpenter"

# EKS cluster name where Karpenter will be deployed
  cluster_name = var.cluster_name

 # Enable Kubernetes v1 API permissions for Karpenter
  enable_v1_permissions = true

  # Enable Pod Identity for Karpenter to authenticate with AWS services
  enable_pod_identity   = true
  create_pod_identity_association = true

  # Attach additional IAM policies to the Karpenter node IAM role
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
}

