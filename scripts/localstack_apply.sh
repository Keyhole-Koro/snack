#!/bin/bash
set -e

# Usage: ./localstack_apply.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
TERRAFORM_DIR="$ROOT_DIR/terraform"

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
"$TERRAFORM_DIR/scripts/create-state-bucket.sh" local

# 3. Init Terraform
echo "▸ Initializing Terraform..."
cd "$TERRAFORM_DIR"

# Configure backend to use S3 (in LocalStack)
# We use partial configuration or specific backend file for local
# For this template, we'll use a local backend file or command line args
# But Terraform S3 backend needs endpoint override which is tricky in purely CLI args without a file.
# The user asked for "backend settings" to be switched.
# A common pattern for LocalStack is using `tflocal` or a backend block that points to local s3.
# Let's assume we use a backend.tf or override it.
# For simplicity in this script, we can generate a backend config or just use local state for local dev?
# The prompt asked for "State Bucket (Terraform execution BEFORE need)".
# So we MUST use S3 backend.

# We create an override file for localstack backend
# Configure backend using localstack.hcl
terraform init -reconfigure -backend-config=backends/localstack.hcl

# 4. Import All
echo "▸ Importing existing resources..."
"$TERRAFORM_DIR/scripts/import_all.sh" tfvars/localstack.tfvars

# 5. Plan
echo "▸ Planning..."
terraform plan -var-file="tfvars/localstack.tfvars" -out=tfplan

# 6. Apply
echo "▸ Applying..."
terraform apply -auto-approve tfplan

# Cleanup temporary backend file if desired, or keep it for subsequent runs.
# rm backend_local.tf
