# modules/rds-postgres/variables.tf

variable "db_name" {
  type        = string
  description = "Name identifier for the RDS instance"
  
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]*$", var.db_name))
    error_message = "Database name must start with a letter and contain only letters, numbers, and hyphens."
  }
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., staging, production)"
  
  validation {
    condition     = contains(["staging", "production", "development"], var.environment)
    error_message = "Environment must be one of: staging, production, development."
  }
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the RDS instance will be created"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for the DB subnet group"
  
  validation {
    condition     = length(var.private_subnet_ids) >= 2
    error_message = "At least 2 private subnets are required for RDS Multi-AZ."
  }
}

variable "allowed_security_groups" {
  type        = list(string)
  description = "List of security group IDs allowed to access the database"
  default     = []
}

# Database Configuration
variable "postgres_version" {
  type        = string
  description = "PostgreSQL version"
  default     = "15.4"
  
  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+$", var.postgres_version))
    error_message = "PostgreSQL version must be in format 'major.minor' (e.g., '15.4')."
  }
}

variable "instance_class" {
  type        = string
  description = "RDS instance class"
  default     = "db.t3.micro"
  
  validation {
    condition = can(regex("^db\\.(t3|t4g|m5|m6i|r5|r6i)\\.(nano|micro|small|medium|large|xlarge|2xlarge|4xlarge|8xlarge|12xlarge|16xlarge|24xlarge)$", var.instance_class))
    error_message = "Instance class must be a valid RDS instance type."
  }
}

variable "database_name" {
  type        = string
  description = "Name of the database to create"
  default     = "attrahere"
  
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]*$", var.database_name))
    error_message = "Database name must start with a letter and contain only letters, numbers, and underscores."
  }
}

variable "db_username" {
  type        = string
  description = "Master username for the database"
  default     = "attrahere_admin"
  
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]*$", var.db_username))
    error_message = "Username must start with a letter and contain only letters, numbers, and underscores."
  }
}

# Storage Configuration
variable "allocated_storage" {
  type        = number
  description = "Initial allocated storage in GB"
  default     = 20
  
  validation {
    condition     = var.allocated_storage >= 20 && var.allocated_storage <= 65536
    error_message = "Allocated storage must be between 20 and 65536 GB."
  }
}

variable "max_allocated_storage" {
  type        = number
  description = "Maximum allocated storage for auto-scaling in GB"
  default     = 100
  
  validation {
    condition     = var.max_allocated_storage >= 20 && var.max_allocated_storage <= 65536
    error_message = "Max allocated storage must be between 20 and 65536 GB."
  }
}

# Backup Configuration
variable "backup_retention_days" {
  type        = number
  description = "Number of days to retain backups"
  default     = 7
  
  validation {
    condition     = var.backup_retention_days >= 0 && var.backup_retention_days <= 35
    error_message = "Backup retention period must be between 0 and 35 days."
  }
}

variable "backup_window" {
  type        = string
  description = "Backup window in UTC (format: HH:MM-HH:MM)"
  default     = "03:00-04:00"
  
  validation {
    condition     = can(regex("^[0-2][0-9]:[0-5][0-9]-[0-2][0-9]:[0-5][0-9]$", var.backup_window))
    error_message = "Backup window must be in format HH:MM-HH:MM."
  }
}

variable "maintenance_window" {
  type        = string
  description = "Maintenance window in UTC (format: ddd:HH:MM-ddd:HH:MM)"
  default     = "sun:04:00-sun:05:00"
  
  validation {
    condition     = can(regex("^(mon|tue|wed|thu|fri|sat|sun):[0-2][0-9]:[0-5][0-9]-(mon|tue|wed|thu|fri|sat|sun):[0-2][0-9]:[0-5][0-9]$", var.maintenance_window))
    error_message = "Maintenance window must be in format ddd:HH:MM-ddd:HH:MM."
  }
}

# Monitoring Configuration
variable "monitoring_interval" {
  type        = number
  description = "Enhanced monitoring interval in seconds (0 to disable, or 1, 5, 10, 15, 30, 60)"
  default     = 60
  
  validation {
    condition     = contains([0, 1, 5, 10, 15, 30, 60], var.monitoring_interval)
    error_message = "Monitoring interval must be 0, 1, 5, 10, 15, 30, or 60 seconds."
  }
}

variable "performance_insights_enabled" {
  type        = bool
  description = "Enable Performance Insights"
  default     = true
}

variable "performance_insights_retention_period" {
  type        = number
  description = "Performance Insights retention period in days"
  default     = 7
  
  validation {
    condition     = contains([7, 731], var.performance_insights_retention_period)
    error_message = "Performance Insights retention period must be 7 or 731 days."
  }
}

# Security Configuration
variable "deletion_protection" {
  type        = bool
  description = "Enable deletion protection"
  default     = true
}

variable "skip_final_snapshot" {
  type        = bool
  description = "Skip final snapshot when deleting"
  default     = false
}