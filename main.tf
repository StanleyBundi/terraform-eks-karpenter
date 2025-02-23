# VPC Module - Creates the network infrastructure for EKS
module "vpc" {
  source       = "./modules/vpc"
  cluster_name = var.cluster_name
  region       = var.region

  providers = {
    aws = aws
  }
}

# EKS Cluster Module - Deploys the EKS control plane
module "eks" {
  source       = "./modules/eks"
  cluster_name = var.cluster_name
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets
  # region       = var.region

  providers = {
    aws = aws
  }
}

# Karpenter Module - Enables autoscaling for Kubernetes workloads
module "karpenter" {
  source               = "./modules/karpenter"
  cluster_name         = var.cluster_name

  providers = {
    aws      = aws
    kubectl  = kubectl
    helm     = helm
  }
}

# Helm Module - Installs Karpenter via Helm
module "helm" {
  source                    = "./modules/helm"
  cluster_name              = module.eks.cluster_name
  cluster_endpoint          = module.eks.cluster_endpoint
  service_account           = module.karpenter.service_account
  queue_name                = module.karpenter.queue_name
  node_iam_role_name        = module.karpenter.node_iam_role_name
  private_subnet_ids        = module.vpc.private_subnets
  intra_subnet_ids          = module.vpc.intra_subnets
  region                    = var.region

  providers = {
    helm    = helm.karpenter
    aws     = aws.virginia
    kubectl = kubectl
  }
}
