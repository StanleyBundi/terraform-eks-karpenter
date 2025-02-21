# Name of the EKS cluster
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

# ID of the VPC where the EKS cluster will be deployed
variable "vpc_id" {
  description = "VPC ID for the EKS cluster"
  type        = string
}

# List of subnet IDs where the EKS cluster nodes will be deployed
variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "control_plane_subnet_ids" {
  description = "List of subnet IDs for the EKS control plane"
  type        = list(string)
}