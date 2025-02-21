# Output the IAM Service Account created for Karpenter
output "service_account" {
  description = "The IAM Service Account for Karpenter"
  value       = module.karpenter.service_account
}

# Output the name of the SQS queue used by Karpenter
output "queue_name" {
  description = "The SQS queue name used by Karpenter"
  value       = module.karpenter.queue_name
}

# Output the IAM role name assigned to Karpenter nodes
output "node_iam_role_name" {
  description = "The IAM role name assigned to Karpenter nodes"
  value       = module.karpenter.node_iam_role_name
}
