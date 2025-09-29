# environments/staging/outputs.tf

# VPC Outputs
output "vpc_id" {
  description = "The ID of the staging VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the staging VPC"
  value       = module.vpc.vpc_cidr_block
}

output "private_subnets" {
  description = "List of IDs of private subnets in the staging VPC"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets in the staging VPC"
  value       = module.vpc.public_subnets
}

# ECR Outputs
output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = module.ecr.repository_url
}

output "ecr_repository_name" {
  description = "Name of the ECR repository"
  value       = module.ecr.repository_name
}

# ECS Outputs
output "ecs_cluster_id" {
  description = "ID of the ECS cluster"
  value       = module.ecs_fargate.cluster_id
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = module.ecs_fargate.service_name
}

output "ecs_log_group_name" {
  description = "Name of the ECS CloudWatch log group"
  value       = module.ecs_fargate.log_group_name
}

# Database Outputs
output "database_endpoint" {
  description = "Database endpoint for application connection"
  value       = module.postgres_db.db_endpoint
  sensitive   = true
}

output "database_port" {
  description = "Database port"
  value       = module.postgres_db.db_port
}

output "database_name" {
  description = "Name of the created database"
  value       = module.postgres_db.db_name
}

output "database_username" {
  description = "Database master username"
  value       = module.postgres_db.db_username
  sensitive   = true
}

output "database_secret_arn" {
  description = "ARN of the database password secret in AWS Secrets Manager"
  value       = module.postgres_db.secrets_manager_secret_arn
}

output "database_connection_string" {
  description = "Database connection string template"
  value       = module.postgres_db.connection_string
  sensitive   = true
}