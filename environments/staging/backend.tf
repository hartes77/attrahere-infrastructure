# Backend configuration for Terraform remote state
terraform {
  backend "s3" {
    bucket         = "attrahere-terraform-state-staging"
    key            = "staging/terraform.tfstate"
    region         = "eu-central-1"
    encrypt        = true
    dynamodb_table = "attrahere-terraform-locks"
  }
}