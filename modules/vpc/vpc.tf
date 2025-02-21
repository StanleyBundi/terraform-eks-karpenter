# VPC Module: Creates a VPC with public, private, and intra subnets
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.13.0"

  name = "${var.cluster_name}-vpc"   # VPC name derived from the cluster name
  cidr = "10.0.0.0/16" # Defines the overall CIDR block for the VPC

   # Defines availability zones and subnets
  azs             = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  intra_subnets   = ["10.0.104.0/24", "10.0.105.0/24", "10.0.106.0/24"]   # Used for control plane

  enable_nat_gateway     = true  # Enables NAT Gateway for private subnets
  single_nat_gateway     = true   # Uses multiple NAT Gateways for high availability
  one_nat_gateway_per_az = false  # Deploys one NAT Gateway per AZ for resilience

 # Tags public subnets for Kubernetes external load balancers
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

# Tags private subnets for internal load balancers and Karpenter auto-discovery
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    # Tags subnets for Karpenter auto-discovery
    "karpenter.sh/discovery" = var.cluster_name
  }
}
