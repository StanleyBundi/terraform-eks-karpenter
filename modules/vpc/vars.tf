# Define the name of the EKS cluster
variable "cluster_name" {
  description = "Name of the cluster"
  type        = string
}

# Specify the AWS region where the infrastructure will be deployed
variable "region" {
  description = "AWS region"
  type        = string
}
