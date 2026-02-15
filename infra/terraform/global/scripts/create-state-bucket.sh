#!/bin/bash
set -e

# Usage: ./create-state-bucket.sh <env>
ENV=$1

if [ -z "$ENV" ]; then
    echo "Usage: $0 <env>"
    exit 1
fi

if [ "$ENV" == "local" ]; then
    BUCKET_NAME="terraform-state-local"
    ENDPOINT="${AWS_ENDPOINT_URL:-http://localhost:4566}"
    PROFILE="default" # or whatever localstack uses
    REGION="us-east-1"
    # AWS CLI wrapper for LocalStack
    AWS_CMD="aws --endpoint-url=$ENDPOINT --region=$REGION"
else
    BUCKET_NAME="terraform-state-${ENV}-snack-12345" # Ensure uniqueness
    AWS_CMD="aws"
fi

echo "Checking if bucket $BUCKET_NAME exists..."
if ! $AWS_CMD s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
    echo "Creating bucket $BUCKET_NAME..."
    $AWS_CMD s3api create-bucket --bucket "$BUCKET_NAME" --region "us-east-1"
    
    echo "Enabling versioning..."
    $AWS_CMD s3api put-bucket-versioning --bucket "$BUCKET_NAME" --versioning-configuration Status=Enabled
    
    echo "Enabling encryption..."
    $AWS_CMD s3api put-bucket-encryption --bucket "$BUCKET_NAME" --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'
else
    echo "Bucket $BUCKET_NAME already exists."
fi
