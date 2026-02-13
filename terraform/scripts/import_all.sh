#!/bin/bash
set -e

# Usage: ./import_all.sh <tfvars_file>
TFVARS_FILE=$1

if [ -z "$TFVARS_FILE" ]; then
    echo "Usage: $0 <tfvars_file>"
    exit 1
fi

# Extract variables (Simple parsing, assumes key = "value")
TABLE_NAME=$(grep 'table_name' "$TFVARS_FILE" | cut -d'=' -f2 | tr -d ' "')
BUCKET_NAME=$(grep 'bucket_name' "$TFVARS_FILE" | cut -d'=' -f2 | tr -d ' "')
ENV=$(grep 'env' "$TFVARS_FILE" | cut -d'=' -f2 | tr -d ' "')

echo "Environment: $ENV"
echo "Table Name: $TABLE_NAME"
echo "Bucket Name: $BUCKET_NAME"

if [ "$ENV" == "local" ]; then
    export AWS_ENDPOINT_URL="http://localhost:4566"
    export AWS_REGION="us-east-1"
    export AWS_ACCESS_KEY_ID="test"
    export AWS_SECRET_ACCESS_KEY="test"
fi

# Function to import if not in state
import_if_exists() {
    ADDR=$1
    ID=$2
    
    # Check if already in state
    if terraform state list | grep -Fq "$ADDR"; then
        echo "Resource $ADDR already in state."
    else
        echo "Importing $ADDR ($ID)..."
        terraform import -var-file="$TFVARS_FILE" "$ADDR" "$ID" || echo "Import failed (maybe resource doesn't exist?)"
    fi
}

# Import DynamoDB Table
import_if_exists "module.db.aws_dynamodb_table.snack_table" "$TABLE_NAME"

# Import S3 Bucket (Frontend)
import_if_exists "module.frontend.aws_s3_bucket.frontend_bucket" "$BUCKET_NAME"

# Import ECR Repo
# import_if_exists "module.simulation.aws_ecr_repository.simulation_repo" "snack-simulation-${ENV}"

# Import ECS Cluster
# import_if_exists "module.simulation.aws_ecs_cluster.snack_cluster" "snack-cluster-${ENV}"

echo "Import check complete."
