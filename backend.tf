# Configure remote backend using S3 for state storage and DynamoDB for state locking.  
# State is encrypted at rest using S3 server-side encryption.  
terraform {
  backend "s3" {
    bucket = "stanley-opsfleet-task-state-bucket"
    region = "eu-west-2"
    key    = "karpenter.tfstate"
    encrypt        = true
    dynamodb_table = "stanley-opsfleet-task-lock-table"
  }
}