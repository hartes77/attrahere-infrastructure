# GitHub Secrets Configuration

## Required Secrets for Infrastructure Deployment

To enable CI/CD deployment, configure the following repository secrets in GitHub:

**Path**: Settings → Secrets and variables → Actions → New repository secret

### Terraform Variables (Staging Environment)

| Secret Name | Value | Description |
|-------------|-------|-------------|
| `TF_VAR_vpc_name` | `"attrahere-staging-vpc"` | Name of the staging VPC |
| `TF_VAR_vpc_cidr` | `"10.0.0.0/16"` | CIDR block for staging VPC |
| `TF_VAR_vpc_azs` | `["eu-central-1a", "eu-central-1b"]` | Availability zones |
| `TF_VAR_vpc_private_subnets` | `["10.0.1.0/24", "10.0.2.0/24"]` | Private subnet CIDRs |
| `TF_VAR_vpc_public_subnets` | `["10.0.101.0/24", "10.0.102.0/24"]` | Public subnet CIDRs |

### AWS Credentials (via OIDC)

Per permettere alla CI/CD di autenticarsi su AWS in modo sicuro, configureremo un provider OIDC. Sarà necessario creare un solo secret contenente l'ARN del ruolo IAM che la pipeline assumerà.

| Secret Name     | Description                                         |
|-----------------|-----------------------------------------------------|
| `AWS_ROLE_ARN`  | L'ARN del ruolo IAM che GitHub Actions assumerà in AWS. |

## Security Notes

- ✅ No sensitive values stored in repository
- ✅ Variables automatically available as `TF_VAR_*` environment variables
- ✅ Secrets encrypted at rest and in transit
- ✅ Access logged and auditable
- ✅ OIDC eliminates static long-lived AWS credentials
- ✅ Temporary credentials with minimal scope

## Usage in Workflows

```yaml
permissions:
  id-token: write   # Required for OIDC
  contents: read

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          aws-region: eu-central-1
          
      - name: Terraform Plan
        env:
          TF_VAR_vpc_name: ${{ secrets.TF_VAR_vpc_name }}
          TF_VAR_vpc_cidr: ${{ secrets.TF_VAR_vpc_cidr }}
          # ... other variables
        run: terraform plan
```