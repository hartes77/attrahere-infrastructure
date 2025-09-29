# modules/rds-postgres/outputs.tf

output "db_instance_id" {
  description = "RDS instance identifier"
  value       = aws_db_instance.postgres.id
}

output "db_instance_arn" {
  description = "RDS instance ARN"
  value       = aws_db_instance.postgres.arn
}

output "db_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.postgres.endpoint
}

output "db_port" {
  description = "RDS instance port"
  value       = aws_db_instance.postgres.port
}

output "db_name" {
  description = "Database name"
  value       = aws_db_instance.postgres.db_name
}

output "db_username" {
  description = "Database master username"
  value       = aws_db_instance.postgres.username
  sensitive   = true
}

output "db_security_group_id" {
  description = "Security group ID for the database"
  value       = aws_security_group.postgres.id
}

output "db_subnet_group_name" {
  description = "Database subnet group name"
  value       = aws_db_subnet_group.postgres.name
}

output "secrets_manager_secret_arn" {
  description = "ARN of the Secrets Manager secret containing database credentials"
  value       = aws_secretsmanager_secret.postgres_password.arn
}

output "secrets_manager_secret_name" {
  description = "Name of the Secrets Manager secret containing database credentials"
  value       = aws_secretsmanager_secret.postgres_password.name
}

output "connection_string" {
  description = "Database connection string template (password should be retrieved from Secrets Manager)"
  value       = "postgresql://${aws_db_instance.postgres.username}:PASSWORD_FROM_SECRETS_MANAGER@${aws_db_instance.postgres.endpoint}:${aws_db_instance.postgres.port}/${aws_db_instance.postgres.db_name}"
  sensitive   = true
}

output "backup_retention_period" {
  description = "Backup retention period in days"
  value       = aws_db_instance.postgres.backup_retention_period
}

output "backup_window" {
  description = "Backup window"
  value       = aws_db_instance.postgres.backup_window
}

output "maintenance_window" {
  description = "Maintenance window"
  value       = aws_db_instance.postgres.maintenance_window
}

output "engine_version" {
  description = "PostgreSQL engine version"
  value       = aws_db_instance.postgres.engine_version
}

output "instance_class" {
  description = "RDS instance class"
  value       = aws_db_instance.postgres.instance_class
}

output "allocated_storage" {
  description = "Allocated storage in GB"
  value       = aws_db_instance.postgres.allocated_storage
}

output "storage_encrypted" {
  description = "Whether storage is encrypted"
  value       = aws_db_instance.postgres.storage_encrypted
}