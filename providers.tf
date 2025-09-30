# providers.tf
provider "aws" {
  region = "eu-central-1" # Francoforte
  # Note: profile is removed for CI/CD - OIDC credentials are used instead

  default_tags {
    tags = {
      Project     = "Attrahere"
      ManagedBy   = "Terraform"
      Environment = "staging"
    }
  }
}