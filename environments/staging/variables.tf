# environments/staging/variables.tf

variable "vpc_name" {
  description = "Name of the staging VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the staging VPC"
  type        = string
}

variable "vpc_azs" {
  description = "Availability zones for the staging VPC"
  type        = list(string)
}

variable "vpc_private_subnets" {
  description = "Private subnets for the staging VPC"
  type        = list(string)
}

variable "vpc_public_subnets" {
  description = "Public subnets for the staging VPC"
  type        = list(string)
}

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "eu-central-1"
}

variable "db_instance_class" {
  description = "RDS instance class for staging environment"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Initial allocated storage for RDS instance (GB)"
  type        = number
  default     = 20
}

variable "db_max_allocated_storage" {
  description = "Maximum allocated storage for RDS autoscaling (GB)"
  type        = number
  default     = 100
}

variable "db_backup_retention_days" {
  description = "Number of days to retain database backups"
  type        = number
  default     = 7
}

variable "db_backup_window" {
  description = "Database backup window in UTC (format: HH:MM-HH:MM)"
  type        = string
  default     = "03:00-04:00"
}

variable "db_maintenance_window" {
  description = "Database maintenance window in UTC (format: ddd:HH:MM-ddd:HH:MM)"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "db_deletion_protection" {
  description = "Enable deletion protection for the database"
  type        = bool
  default     = true
}

variable "db_skip_final_snapshot" {
  description = "Skip final snapshot when deleting database"
  type        = bool
  default     = false
}