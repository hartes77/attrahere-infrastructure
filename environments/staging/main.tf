# environments/staging/main.tf
# Staging environment for Attrahere Platform

module "vpc" {
  source = "../../modules/vpc"

  vpc_name = var.vpc_name
  vpc_cidr = var.vpc_cidr

  vpc_azs             = var.vpc_azs
  vpc_private_subnets = var.vpc_private_subnets
  vpc_public_subnets  = var.vpc_public_subnets

  environment = "staging"
}

# ECR Repository for container images
module "ecr" {
  source = "../../modules/ecr"

  repository_name = "attrahere-platform"
  environment     = "staging"
  
  common_tags = {
    Project     = "Attrahere"
    Environment = "staging"
    Terraform   = "true"
  }
}

# ECS Fargate service
module "ecs_fargate" {
  source = "../../modules/ecs-fargate"

  cluster_name    = "attrahere-staging"
  container_image = "${module.ecr.repository_url}:staging-latest"
  
  vpc_id             = module.vpc.vpc_id
  vpc_cidr           = module.vpc.vpc_cidr_block
  private_subnet_ids = module.vpc.private_subnets
  aws_region         = var.aws_region
  
  environment   = "staging"
  desired_count = 1
  task_cpu      = 512
  task_memory   = 1024
  
  common_tags = {
    Project     = "Attrahere"
    Environment = "staging"
    Terraform   = "true"
  }
}

# PostgreSQL RDS Database
module "postgres_db" {
  source = "../../modules/rds-postgres"

  # --- Parametri Base ---
  db_name     = "attrahere-staging-db"
  environment = "staging"

  # --- Configurazione Istanza ---
  instance_class        = var.db_instance_class
  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  
  # --- Configurazione di Rete e Sicurezza ---
  vpc_id                  = module.vpc.vpc_id
  private_subnet_ids      = module.vpc.private_subnets
  allowed_security_groups = [module.ecs_fargate.security_group_id]

  # --- Configurazione Backup e Manutenzione ---
  backup_retention_days = var.db_backup_retention_days
  backup_window         = var.db_backup_window
  maintenance_window    = var.db_maintenance_window
  
  # --- Configurazione Sicurezza ---
  deletion_protection = var.db_deletion_protection
  skip_final_snapshot = var.db_skip_final_snapshot

  # --- Monitoraggio ---
  monitoring_interval              = 60
  performance_insights_enabled    = true
  performance_insights_retention_period = 7
}