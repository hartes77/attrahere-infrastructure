# backend.tf
terraform {
  backend "s3" {
    bucket         = "attrahere-terraform-state-prod" # Sostituisci con il nome del bucket S3 creato
    key            = "global/s3/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "attrahere-terraform-locks"   # Sostituisci con il nome della tabella DynamoDB
    encrypt        = true
  }
}