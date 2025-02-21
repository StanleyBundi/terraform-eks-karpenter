# Region
variable "region" {
  description = "The AWS region where resources will be deployed"
  type        = string
  default     = "eu-west-2"
}

# s3 Bucket Name
variable "s3_bucket_name" {
  description = "The name of the S3 bucket for Terraform state"
  type        = string
  default     = "stanley-opsfleet-task-state-bucket"
}

# DynamoDB Table Name
variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table for state locking"
  type        = string
  default     = "stanley-opsfleet-task-lock-table"
}

