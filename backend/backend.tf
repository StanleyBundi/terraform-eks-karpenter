# This configuration creates an S3 bucket for Terraform state storage with versioning and AES256 encryption.
resource "aws_s3_bucket" "terraform_state" {
  bucket        = var.s3_bucket_name
  force_destroy = true

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name = "Terraform State Bucket"
  }
}

# Separate resource for managing S3 bucket versioning
resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Separate resource for managing S3 bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "sse_config" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


# This configuration creates a DynamoDB table for Terraform state locking to prevent concurrent state modifications.
resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "Terraform Lock Table"
  }
}
