# Output the name of the IAM service account role for Karpenter
output "service_account" {
  description = "The service account for Karpenter"
  value       = module.karpenter.service_account
}

# Output the name of the SQS queue used by Karpenter for handling instance lifecycle events
output "queue_name" {
  description = "The name of the SQS queue used by Karpenter"
  value       = module.karpenter.queue_name
}

# Output the IAM role name assigned to Karpenter-provisioned EC2 nodes
output "node_iam_role_name" {
  description = "The IAM role name assigned to Karpenter nodes"
  value       = module.karpenter.node_iam_role_name
}
