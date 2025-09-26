# modules/vpc/main.tf

# Utilizziamo il modulo VPC ufficiale e testato dalla community
# https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.vpc_azs
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  enable_nat_gateway   = true
  single_nat_gateway   = true # Per ottimizzare i costi in fase iniziale
  enable_dns_hostnames = true

  tags = {
    "Terraform"   = "true"
    "Environment" = var.environment
    "Project"     = "attrahere"
    "Owner"       = "platform-team"
  }
}