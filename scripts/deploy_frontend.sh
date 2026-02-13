#!/bin/bash
set -e

# Usage: ./deploy_frontend.sh <BUCKET_NAME>
BUCKET_NAME=$1

if [ -z "$BUCKET_NAME" ]; then
  echo "Usage: ./deploy_frontend.sh <BUCKET_NAME>"
  exit 1
fi

echo "▸ Building Frontend..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$ROOT_DIR/snackWeb/frontend"
npm install
npm run build

echo "▸ Deploying to s3://$BUCKET_NAME ..."
aws s3 sync dist/ s3://$BUCKET_NAME --delete

echo "✅ Deployment Complete."
echo "Don't forget to invalidate CloudFront if needed:"
echo "aws cloudfront create-invalidation --distribution-id <DIST_ID> --paths \"/*\""
