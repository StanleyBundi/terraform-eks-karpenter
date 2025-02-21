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

# IAM role for Karpenter service account to interact with EKS
resource "aws_iam_role" "karpenter_sa" {
  name = "${var.cluster_name}-karpenter-sa"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com" # Allows EKS to assume this role
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# SQS queue used by Karpenter for handling instance lifecycle events
resource "aws_sqs_queue" "karpenter_queue" {
  name                      = "${var.cluster_name}-karpenter-queue"
  message_retention_seconds = 300 # Messages retained for 5 minutes
}

# IAM role for Karpenter-provisioned EC2 nodes
resource "aws_iam_role" "karpenter_node_role" {
  name = "${var.cluster_name}-karpenter-node-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com" # Allows EC2 instances to assume this role
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}
