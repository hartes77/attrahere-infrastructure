# modules/ecs-fargate/secrets.tf
# AWS Secrets Manager integration for ECS Fargate (ENTERPRISE-SAFE)
# IMPORTANT: Secret VALUES are NOT managed by Terraform to avoid state exposure
# Values are populated via CI/CD pipeline using AWS CLI put-secret-value

# Database URL Secret (metadata only - value populated by CI/CD)
resource "aws_secretsmanager_secret" "database_url" {
  name                    = "${var.environment}/attrahere/database_url"
  description             = "Complete DATABASE_URL for Attrahere Platform ${var.environment} environment"
  recovery_window_in_days = var.environment == "production" ? 30 : 7

  tags = merge(var.common_tags, {
    Name        = "${var.environment}/attrahere/database_url"
    Environment = var.environment
    Component   = "secrets-manager"
    SecretType  = "database-url"
  })
}

# API Secret Key (metadata only - value populated by CI/CD)
resource "aws_secretsmanager_secret" "api_secret_key" {
  name                    = "${var.environment}/attrahere/api_secret_key"
  description             = "API Secret Key for Attrahere Platform ${var.environment} environment"
  recovery_window_in_days = var.environment == "production" ? 30 : 7

  tags = merge(var.common_tags, {
    Name        = "${var.environment}/attrahere/api_secret_key"
    Environment = var.environment
    Component   = "secrets-manager"
    SecretType  = "api-key"
  })
}

# JWT Secret (metadata only - value populated by CI/CD)
resource "aws_secretsmanager_secret" "jwt_secret" {
  name                    = "${var.environment}/attrahere/jwt_secret"
  description             = "JWT Secret for Attrahere Platform ${var.environment} environment"
  recovery_window_in_days = var.environment == "production" ? 30 : 7

  tags = merge(var.common_tags, {
    Name        = "${var.environment}/attrahere/jwt_secret"
    Environment = var.environment
    Component   = "secrets-manager"
    SecretType  = "jwt"
  })
}

# Database Password Secret (metadata only - supports rotation)
resource "aws_secretsmanager_secret" "database_password" {
  name                    = "${var.environment}/attrahere/database_password"
  description             = "Database password for Attrahere Platform ${var.environment} environment"
  recovery_window_in_days = var.environment == "production" ? 30 : 7

  # Note: Automatic rotation will be configured separately via aws_secretsmanager_secret_rotation

  tags = merge(var.common_tags, {
    Name        = "${var.environment}/attrahere/database_password"
    Environment = var.environment
    Component   = "secrets-manager"
    SecretType  = "database-password"
  })
}

# KMS Key for Secrets (optional, for additional security)
resource "aws_kms_key" "secrets" {
  count                   = var.use_custom_kms_key ? 1 : 0
  description             = "KMS key for Attrahere ${var.environment} secrets encryption"
  deletion_window_in_days = var.environment == "production" ? 30 : 7

  tags = merge(var.common_tags, {
    Name        = "attrahere-${var.environment}-secrets-key"
    Environment = var.environment
    Component   = "kms"
  })
}

resource "aws_kms_alias" "secrets" {
  count         = var.use_custom_kms_key ? 1 : 0
  name          = "alias/attrahere-${var.environment}-secrets"
  target_key_id = aws_kms_key.secrets[0].key_id
}