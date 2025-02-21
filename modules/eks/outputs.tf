# Outputs the EKS cluster name
output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

# Outputs the API endpoint for interacting with the EKS cluster
output "cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = module.eks.cluster_endpoint
}

# Outputs a list of ARNs for the managed node groups
output "eks_managed_node_group_arns" {
  description = "List of ARNs of the managed node groups"
  value       = values(module.eks.eks_managed_node_groups)[*].node_group_arn
}

# Outputs the names of the managed node groups
output "eks_managed_node_group_names" {
  description = "List of managed node group names"
  value       = keys(module.eks.eks_managed_node_groups)
}

# Outputs the Base64-encoded certificate authority (CA) data for the cluster
output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate authority data for the cluster"
  value       = module.eks.cluster_certificate_authority_data
}