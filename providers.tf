# providers.tf
provider "aws" {
  region = "eu-central-1" # Francoforte

  default_tags {
    tags = {
      Project     = "Attrahere"
      ManagedBy   = "Terraform"
    }
  }
}