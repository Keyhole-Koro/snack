#!/bin/bash
set -e

# Usage: ./localstack_apply.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
TERRAFORM_PERSONA_DIR="$ROOT_DIR/infra/terraform/persona"
TERRAFORM_WEB_DIR="$ROOT_DIR/infra/terraform/web"

echo "🍿 Deploying to LocalStack..."

# 1. Install Dependencies (Skipped for now, assuming terraform is installed)
# In DevContainer, terraform is installed.
# We might need tflocal wrapper or just use endpoint overrides.
# Using 'terraform' with standard AWS provider and custom endpoints/profile.

export AWS_ACCESS_KEY_ID="test"
export AWS_SECRET_ACCESS_KEY="test"
export AWS_REGION="us-east-1"
# Critical for LocalStack + Terraform interaction
export AWS_ENDPOINT_URL="http://localhost:4566"

# 2. Create State Bucket
echo "▸ Creating State Bucket..."
"$ROOT_DIR/infra/terraform/global/scripts/create-state-bucket.sh" local

# 3. Apply snackPersona stack
echo "▸ Initializing snackPersona Terraform..."
cd "$TERRAFORM_PERSONA_DIR"
terraform init -reconfigure -backend-config=backends/localstack.hcl

echo "▸ Importing snackPersona resources..."
./scripts/import.sh tfvars/localstack.tfvars

echo "▸ Planning snackPersona..."
terraform plan -var-file="tfvars/localstack.tfvars" -out=tfplan

echo "▸ Applying snackPersona..."
terraform apply -auto-approve tfplan

# 4. Apply snackWeb stack
echo "▸ Initializing snackWeb Terraform..."
cd "$TERRAFORM_WEB_DIR"
terraform init -reconfigure -backend-config=backends/localstack.hcl

echo "▸ Importing snackWeb resources..."
./scripts/import.sh tfvars/localstack.tfvars

echo "▸ Planning snackWeb..."
terraform plan -var-file="tfvars/localstack.tfvars" -out=tfplan

echo "▸ Applying snackWeb..."
terraform apply -auto-approve tfplan
