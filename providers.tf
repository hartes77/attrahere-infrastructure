# providers.tf
provider "aws" {
  region  = "eu-central-1" # Francoforte
  profile = "482352877352_AdministratorAccess"

  default_tags {
    tags = {
      Project     = "Attrahere"
      ManagedBy   = "Terraform"
    }
  }
}