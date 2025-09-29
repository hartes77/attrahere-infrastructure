# backend.tf
terraform {
  backend "s3" {
    bucket         = "attrahere-terraform-state-482352877352" # S3 bucket created
    key            = "global/s3/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "attrahere-terraform-locks"   # DynamoDB table created
    encrypt        = true
  }
}