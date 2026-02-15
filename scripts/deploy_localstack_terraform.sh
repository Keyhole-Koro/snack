#!/usr/bin/env bash
set -euo pipefail

# Deploy Terraform stack(s) to LocalStack.
#
# Usage:
#   ./scripts/deploy_localstack_terraform.sh
#   ./scripts/deploy_localstack_terraform.sh global
#   ./scripts/deploy_localstack_terraform.sh global full
#
# Notes:
# - Default stack is "global" because it contains valid local service modules.
# - This script auto-detects LocalStack endpoint from:
#   1) existing AWS_ENDPOINT_URL
#   2) http://localhost:4566
#   3) http://localstack:4566

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STACK="${1:-global}"
MODE="${2:-db-only}"

export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:-test}"
export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:-test}"
export AWS_REGION="${AWS_REGION:-us-east-1}"

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "error: required command not found: $1" >&2
    exit 1
  }
}

require_cmd terraform
require_cmd aws

detect_localstack_endpoint() {
  local candidates=()
  if [[ -n "${AWS_ENDPOINT_URL:-}" ]]; then
    candidates+=("${AWS_ENDPOINT_URL}")
  fi
  candidates+=("http://localhost:4566" "http://localstack:4566")

  for ep in "${candidates[@]}"; do
    if aws --endpoint-url="$ep" --region="$AWS_REGION" sts get-caller-identity >/dev/null 2>&1; then
      echo "$ep"
      return 0
    fi
  done
  return 1
}

if ! AWS_ENDPOINT_URL="$(detect_localstack_endpoint)"; then
  echo "error: LocalStack endpoint is not reachable (tried: ${AWS_ENDPOINT_URL:-unset}, http://localhost:4566, http://localstack:4566)" >&2
  echo "hint: start it first: docker compose up -d localstack" >&2
  exit 1
fi
export AWS_ENDPOINT_URL

echo "LocalStack endpoint is reachable: $AWS_ENDPOINT_URL"

if [[ "$STACK" != "global" ]]; then
  echo "error: unsupported stack '$STACK'" >&2
  echo "supported stacks: global" >&2
  exit 1
fi

if [[ "$MODE" != "db-only" && "$MODE" != "full" ]]; then
  echo "error: unsupported mode '$MODE'" >&2
  echo "supported modes: db-only, full" >&2
  exit 1
fi

TF_DIR="$ROOT_DIR/infra/terraform/$STACK"
TFVARS="$TF_DIR/tfvars/localstack.tfvars"
BACKEND="$TF_DIR/backends/localstack.hcl"

if [[ ! -d "$TF_DIR" ]]; then
  echo "error: stack directory not found: $TF_DIR" >&2
  exit 1
fi

if [[ ! -f "$TFVARS" || ! -f "$BACKEND" ]]; then
  echo "error: localstack tfvars/backend config missing in $TF_DIR" >&2
  exit 1
fi

echo "Creating Terraform state bucket for local backend..."
"$ROOT_DIR/infra/terraform/global/scripts/create-state-bucket.sh" local

BACKEND_TMP="$(mktemp)"
trap 'rm -f "$BACKEND_TMP"' EXIT
cp "$BACKEND" "$BACKEND_TMP"
# Keep backend files static in repo; patch endpoint in a temp copy at runtime.
sed -i "s|http://localhost:4566|$AWS_ENDPOINT_URL|g" "$BACKEND_TMP"

echo "Terraform init ($STACK)..."
terraform -chdir="$TF_DIR" init -reconfigure -backend-config="$BACKEND_TMP"

if [[ -x "$TF_DIR/scripts/import.sh" ]]; then
  echo "Importing existing resources ($STACK)..."
  "$TF_DIR/scripts/import.sh" "$TFVARS"
fi

echo "Terraform apply ($STACK)..."
if [[ "$MODE" == "db-only" ]]; then
  echo "Applying db-only target (module.db) for LocalStack compatibility..."
  terraform -chdir="$TF_DIR" apply -auto-approve -var-file="$TFVARS" -target=module.db
else
  terraform -chdir="$TF_DIR" apply -auto-approve -var-file="$TFVARS"
fi

echo "Done: deployed '$STACK' ($MODE) to LocalStack."
