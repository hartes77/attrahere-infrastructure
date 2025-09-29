# modules/rds-postgres/main.tf

# Create DB subnet group for RDS
resource "aws_db_subnet_group" "postgres" {
  name       = "${var.db_name}-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name        = "${var.db_name}-subnet-group"
    Environment = var.environment
    Project     = "attrahere"
    Owner       = "platform-team"
  }
}

# Security group for RDS PostgreSQL
resource "aws_security_group" "postgres" {
  name_prefix = "${var.db_name}-postgres-"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = var.allowed_security_groups
    description     = "PostgreSQL access from application layer"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = {
    Name        = "${var.db_name}-postgres-sg"
    Environment = var.environment
    Project     = "attrahere"
    Owner       = "platform-team"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Random password for database
resource "random_password" "postgres_password" {
  length  = 32
  special = true
}

# Store password in AWS Secrets Manager
resource "aws_secretsmanager_secret" "postgres_password" {
  name                    = "${var.db_name}-postgres-password"
  description             = "PostgreSQL password for ${var.db_name}"
  recovery_window_in_days = 7

  tags = {
    Environment = var.environment
    Project     = "attrahere"
    Owner       = "platform-team"
  }
}

resource "aws_secretsmanager_secret_version" "postgres_password" {
  secret_id = aws_secretsmanager_secret.postgres_password.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.postgres_password.result
  })
}

# RDS PostgreSQL instance
resource "aws_db_instance" "postgres" {
  identifier     = var.db_name
  engine         = "postgres"
  engine_version = var.postgres_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.database_name
  username = var.db_username
  password = random_password.postgres_password.result

  vpc_security_group_ids = [aws_security_group.postgres.id]
  db_subnet_group_name   = aws_db_subnet_group.postgres.name

  backup_retention_period = var.backup_retention_days
  backup_window          = var.backup_window
  maintenance_window     = var.maintenance_window

  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.db_name}-final-snapshot"

  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_interval > 0 ? aws_iam_role.rds_enhanced_monitoring[0].arn : null

  performance_insights_enabled = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null

  deletion_protection = var.deletion_protection

  tags = {
    Name        = var.db_name
    Environment = var.environment
    Project     = "attrahere"
    Owner       = "platform-team"
  }

  depends_on = [aws_db_subnet_group.postgres]
}

# IAM role for enhanced monitoring (optional)
resource "aws_iam_role" "rds_enhanced_monitoring" {
  count = var.monitoring_interval > 0 ? 1 : 0
  name  = "${var.db_name}-rds-enhanced-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
    Project     = "attrahere"
    Owner       = "platform-team"
  }
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  count      = var.monitoring_interval > 0 ? 1 : 0
  role       = aws_iam_role.rds_enhanced_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}