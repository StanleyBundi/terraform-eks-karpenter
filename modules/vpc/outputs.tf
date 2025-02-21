# Output the VPC ID
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

# Output the list of private subnet IDs (used for internal workloads and worker nodes)
output "private_subnets" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnets
}

# Output the list of public subnet IDs (used for internet-facing services like ALB)
output "public_subnets" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnets
}

# Output the list of intra subnet IDs (typically used for internal communication, control plane, or services without NAT)
output "intra_subnets" {
  description = "List of intra subnet IDs"
  value       = module.vpc.intra_subnets
}
