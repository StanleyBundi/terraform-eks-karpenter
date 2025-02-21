# AWS region where resources will be deployed
variable "region" {
  description = "AWS region for deploying resources"
  type        = string
}

# Name of the Amazon EKS cluster
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

# API endpoint of the EKS cluster
variable "cluster_endpoint" {
  description = "Endpoint of the EKS cluster"
  type        = string
}

# Kubernetes service account name for Karpenter
variable "service_account" {
  description = "Karpenter Service Account"
  type        = string
}

# Name of the SQS queue used by Karpenter for handling interruptions
variable "queue_name" {
  description = "Karpenter SQS Queue Name"
  type        = string
}

# IAM role assigned to nodes provisioned by Karpenter
variable "node_iam_role_name" {
  description = "IAM Role Name for Karpenter Nodes"
  type        = string
}

# List of private subnet IDs where EKS worker nodes will be deployed
variable "private_subnet_ids" {
  description = "List of private subnet IDs for EKS cluster"
  type        = list(string)
}

# List of intra subnet IDs used for EKS control plane components
variable "intra_subnet_ids" {
  description = "List of intra subnet IDs for EKS cluster"
  type        = list(string)
}
