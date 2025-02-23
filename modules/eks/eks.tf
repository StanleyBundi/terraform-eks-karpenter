# EKS Cluster Module: Deploys an Amazon EKS cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.33.1"

  cluster_name    = var.cluster_name
  cluster_version = "1.32"

    # Restrict public API access to trusted IPs 
  cluster_endpoint_public_access  = true
  # cluster_endpoint_public_access_cidrs = [""]  # Enter a trusted IP

  #vpc_id                   = module.vpc.vpc_id
  #subnet_ids               = module.vpc.private_subnets
  vpc_id                     = var.vpc_id
  subnet_ids                 = var.subnet_ids
  control_plane_subnet_ids   = var.control_plane_subnet_ids
  

    # Enable control plane logging for better debugging
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # cluster add-ons to ensure networking and authentication services function correctly
  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  # managed node group (MNG) to host critical Kubernetes system components
  eks_managed_node_groups = {
    critical_addons = {
      ami_type       = "AL2023_ARM_64_STANDARD" 
      instance_types = ["c7g.large", "m7g.large"]  
      
      #  min_size to 2 for redundancy
      min_size     = 2
      max_size     = 4
      desired_size = 2
      
      taints = {
        addons = {
          key    = "CriticalAddonsOnly"
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      }
      
      capacity_type = "ON_DEMAND"  # Ensures stability for core add-ons
    }
  }

  # Ensures IAM admin access for the cluster creator
  enable_cluster_creator_admin_permissions = true

}

