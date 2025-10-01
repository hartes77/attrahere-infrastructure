#!/bin/bash
# populate-secrets.sh
# Enterprise-safe secret population for Attrahere Platform
# This script should be run from CI/CD pipeline or admin workstation
# NEVER commit actual secret values to repository

set -euo pipefail

# Configuration
ENVIRONMENT=${1:-staging}
AWS_REGION=${AWS_REGION:-eu-central-1}
AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID:-482352877352}

# Color output for clarity
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(staging|production)$ ]]; then
    log_error "Environment must be 'staging' or 'production'"
    exit 1
fi

log_info "Populating secrets for environment: $ENVIRONMENT"

# Construct secret ARNs
DATABASE_URL_SECRET="arn:aws:secretsmanager:${AWS_REGION}:${AWS_ACCOUNT_ID}:secret:${ENVIRONMENT}/attrahere/database_url"
DATABASE_PASSWORD_SECRET="arn:aws:secretsmanager:${AWS_REGION}:${AWS_ACCOUNT_ID}:secret:${ENVIRONMENT}/attrahere/database_password"
API_SECRET_KEY_SECRET="arn:aws:secretsmanager:${AWS_REGION}:${AWS_ACCOUNT_ID}:secret:${ENVIRONMENT}/attrahere/api_secret_key"
JWT_SECRET_SECRET="arn:aws:secretsmanager:${AWS_REGION}:${AWS_ACCOUNT_ID}:secret:${ENVIRONMENT}/attrahere/jwt_secret"

# Function to check if secret exists
check_secret_exists() {
    local secret_arn=$1
    if aws secretsmanager describe-secret --secret-id "$secret_arn" --region "$AWS_REGION" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Function to populate secret safely
populate_secret() {
    local secret_arn=$1
    local secret_name=$2
    local prompt_message=$3
    
    if check_secret_exists "$secret_arn"; then
        log_info "Secret $secret_name exists. Updating value..."
        
        # Read secret value securely (not echoed)
        echo -n "$prompt_message: "
        read -s secret_value
        echo
        
        if [[ -z "$secret_value" ]]; then
            log_warn "Empty value provided for $secret_name. Skipping..."
            return
        fi
        
        # Update secret value
        aws secretsmanager put-secret-value \
            --secret-id "$secret_arn" \
            --secret-string "$secret_value" \
            --region "$AWS_REGION" \
            >/dev/null
            
        log_info "✅ Secret $secret_name updated successfully"
    else
        log_error "Secret $secret_name does not exist. Run terraform apply first."
        exit 1
    fi
}

# Generate DATABASE_URL from components
generate_database_url() {
    echo -n "Enter DB username [attrahere_admin]: "
    read db_user
    db_user=${db_user:-attrahere_admin}
    
    echo -n "Enter DB password: "
    read -s db_password
    echo
    
    echo -n "Enter DB host [attrahere-${ENVIRONMENT}-db.cbwuym2qcqn9.eu-central-1.rds.amazonaws.com]: "
    read db_host
    db_host=${db_host:-attrahere-${ENVIRONMENT}-db.cbwuym2qcqn9.eu-central-1.rds.amazonaws.com}
    
    echo -n "Enter DB port [5432]: "
    read db_port
    db_port=${db_port:-5432}
    
    echo -n "Enter DB name [attrahere]: "
    read db_name
    db_name=${db_name:-attrahere}
    
    # Construct DATABASE_URL
    DATABASE_URL="postgresql+asyncpg://${db_user}:${db_password}@${db_host}:${db_port}/${db_name}"
    
    # Update DATABASE_URL secret
    aws secretsmanager put-secret-value \
        --secret-id "$DATABASE_URL_SECRET" \
        --secret-string "$DATABASE_URL" \
        --region "$AWS_REGION" \
        >/dev/null
        
    log_info "✅ DATABASE_URL secret updated successfully"
    
    # Also update database password secret separately for rotation
    aws secretsmanager put-secret-value \
        --secret-id "$DATABASE_PASSWORD_SECRET" \
        --secret-string "$db_password" \
        --region "$AWS_REGION" \
        >/dev/null
        
    log_info "✅ Database password secret updated successfully"
}

# Main execution
log_info "Starting secret population for $ENVIRONMENT environment..."

# Generate and populate DATABASE_URL
log_info "=== DATABASE_URL Configuration ==="
generate_database_url

# Populate API Secret Key
log_info "=== API Secret Key Configuration ==="
populate_secret "$API_SECRET_KEY_SECRET" "API_SECRET_KEY" "Enter API secret key (32+ chars recommended)"

# Populate JWT Secret
log_info "=== JWT Secret Configuration ==="
populate_secret "$JWT_SECRET_SECRET" "JWT_SECRET" "Enter JWT secret (64+ chars recommended)"

log_info "🎉 All secrets populated successfully for $ENVIRONMENT environment!"
log_warn "Remember to:"
log_warn "  1. Test the ECS deployment after secret updates"
log_warn "  2. Monitor CloudWatch logs for any startup issues"
log_warn "  3. Run smoke tests against /health endpoint"
log_warn "  4. Never commit actual secret values to any repository"

echo
log_info "Next steps:"
echo "  terraform plan -target=module.ecs_fargate"
echo "  terraform apply -target=module.ecs_fargate"
echo "  aws ecs update-service --cluster attrahere-$ENVIRONMENT --service attrahere-platform-service --force-new-deployment"