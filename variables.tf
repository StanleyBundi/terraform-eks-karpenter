# Environment
variable "region" {
    type = string
}

# Cluster Name 
variable "cluster_name" {
    type = string
}

# Karpenter IAM role
variable "karpenter_iam_role" {
  description = "IAM Role for Karpenter nodes"
  type        = string
}