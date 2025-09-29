# 🔐 GitHub Secrets Setup Guide - Attrahere Platform

**Purpose**: Configure GitHub repository secrets for secure OIDC-based deployment to AWS staging environment.

**Prerequisites**: 
- AWS Account created with admin access
- AWS CLI configured locally
- Terraform initialized for attrahere-infrastructure

---

## **Phase 1: AWS IAM OIDC Configuration**

### **Step 1: Create OIDC Identity Provider**

```bash
# Create OIDC provider for GitHub Actions
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1 \
  --client-id-list sts.amazonaws.com
```

### **Step 2: Create IAM Role for GitHub Actions**

Create file: `github-actions-role-policy.json`

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:hartes77/attrahere-infrastructure:*"
        }
      }
    }
  ]
}
```

**Replace `ACCOUNT_ID` with your actual AWS Account ID**

```bash
# Create the IAM role
aws iam create-role \
  --role-name GitHubActions-AttrahereStaging \
  --assume-role-policy-document file://github-actions-role-policy.json

# Attach policies (minimum required permissions)
aws iam attach-role-policy \
  --role-name GitHubActions-AttrahereStaging \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser

aws iam attach-role-policy \
  --role-name GitHubActions-AttrahereStaging \
  --policy-arn arn:aws:iam::aws:policy/AmazonECS_FullAccess

# Custom policy for Terraform state access
aws iam attach-role-policy \
  --role-name GitHubActions-AttrahereStaging \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess

aws iam attach-role-policy \
  --role-name GitHubActions-AttrahereStaging \
  --policy-arn arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess
```

---

## **Phase 2: AWS Secrets Manager Setup**

### **Step 1: Create Database Password**

```bash
# Generate secure random password
DB_PASSWORD=$(openssl rand -base64 32)

# Store in Secrets Manager
aws secretsmanager create-secret \
  --name "staging/attrahere/database_password" \
  --description "PostgreSQL password for staging environment" \
  --secret-string "$DB_PASSWORD" \
  --region eu-central-1
```

### **Step 2: Create API Secret Key**

```bash
# Generate API secret key
API_SECRET=$(openssl rand -hex 32)

# Store in Secrets Manager
aws secretsmanager create-secret \
  --name "staging/attrahere/api_secret_key" \
  --description "FastAPI secret key for staging" \
  --secret-string "$API_SECRET" \
  --region eu-central-1
```

### **Step 3: Create JWT Secret**

```bash
# Generate JWT signing key
JWT_SECRET=$(openssl rand -base64 64)

# Store in Secrets Manager
aws secretsmanager create-secret \
  --name "staging/attrahere/jwt_secret" \
  --description "JWT signing secret for staging" \
  --secret-string "$JWT_SECRET" \
  --region eu-central-1
```

---

## **Phase 3: GitHub Repository Secrets Configuration**

**Location**: GitHub → Settings → Secrets and variables → Actions

### **Required Secrets**

| Secret Name | Value | Description |
|-------------|-------|-------------|
| `AWS_ROLE_TO_ASSUME` | `arn:aws:iam::ACCOUNT_ID:role/GitHubActions-AttrahereStaging` | IAM Role ARN for OIDC |
| `AWS_ACCOUNT_ID` | `123456789012` | Your 12-digit AWS Account ID |

**Example:**
```
AWS_ROLE_TO_ASSUME = arn:aws:iam::123456789012:role/GitHubActions-AttrahereStaging
AWS_ACCOUNT_ID = 123456789012
```

### **Environment-Specific Configuration**

**GitHub → Settings → Environments → Create "staging" environment**

**Environment Secrets:**
- Protection rules: Require reviewers (optional for staging)
- Deployment protection rules: None (for automated deployment)

---

## **Phase 4: Terraform Backend Setup**

### **Step 1: Create S3 Bucket for State**

```bash
# Create S3 bucket (globally unique name)
aws s3 mb s3://attrahere-terraform-state-prod --region eu-central-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket attrahere-terraform-state-prod \
  --versioning-configuration Status=Enabled

# Enable encryption
aws s3api put-bucket-encryption \
  --bucket attrahere-terraform-state-prod \
  --server-side-encryption-configuration '{
    "Rules": [
      {
        "ApplyServerSideEncryptionByDefault": {
          "SSEAlgorithm": "AES256"
        }
      }
    ]
  }'
```

### **Step 2: Create DynamoDB Table for Locking**

```bash
# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name attrahere-terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1 \
  --region eu-central-1
```

---

## **Phase 5: Validation Checklist**

### **✅ Pre-Deployment Verification**

- [ ] AWS Account ID confirmed and documented
- [ ] OIDC provider created successfully
- [ ] IAM role `GitHubActions-AttrahereStaging` exists
- [ ] All secrets created in AWS Secrets Manager
- [ ] GitHub repository secrets configured
- [ ] S3 bucket and DynamoDB table operational
- [ ] `staging.tfvars` file created from template

### **✅ Security Validation**

```bash
# Test OIDC role assumption (run locally)
aws sts assume-role \
  --role-arn arn:aws:iam::ACCOUNT_ID:role/GitHubActions-AttrahereStaging \
  --role-session-name test-session

# Verify secrets exist
aws secretsmanager list-secrets --region eu-central-1

# Test S3 bucket access
aws s3 ls s3://attrahere-terraform-state-prod
```

---

## **Emergency Procedures**

### **Secret Rotation**

```bash
# Rotate database password
NEW_DB_PASSWORD=$(openssl rand -base64 32)
aws secretsmanager update-secret \
  --secret-id "staging/attrahere/database_password" \
  --secret-string "$NEW_DB_PASSWORD"
```

### **Role Cleanup** (if needed)

```bash
# Remove role and policies
aws iam detach-role-policy --role-name GitHubActions-AttrahereStaging --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser
aws iam detach-role-policy --role-name GitHubActions-AttrahereStaging --policy-arn arn:aws:iam::aws:policy/AmazonECS_FullAccess
aws iam delete-role --role-name GitHubActions-AttrahereStaging
```

---

**🎯 Ready for Deployment**: Once all steps are completed, the infrastructure is ready for `terraform plan` and subsequent `terraform apply` with full security compliance.