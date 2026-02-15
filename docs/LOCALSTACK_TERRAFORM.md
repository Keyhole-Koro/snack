# LocalStack Terraform Deployment

This guide explains how to deploy the Terraform stack to LocalStack and verify that the app can use DynamoDB.

## Scope

Current supported stack in the helper script:

- `global` (`infra/terraform/global`)

This is enough to provision `SnackTable` for `snackpersona`.

## Prerequisites

- Docker + Docker Compose
- `terraform` installed
- `aws` CLI installed

## 1. Start LocalStack

```bash
docker compose up -d localstack
```

## 2. Deploy Terraform to LocalStack

Use the provided script:

```bash
./scripts/deploy_localstack_terraform.sh
```

Equivalent explicit command:

```bash
./scripts/deploy_localstack_terraform.sh global
```

Endpoint note:

- Host shell: usually `http://localhost:4566`
- DevContainer / compose network shell: usually `http://localstack:4566`
- The script auto-detects both.

What the script does:

1. Verifies LocalStack endpoint (`http://localhost:4566`) is reachable.
2. Exports LocalStack AWS env vars (`AWS_ENDPOINT_URL`, test credentials, region).
3. Creates/ensures Terraform state bucket.
4. Runs Terraform `init` with `backends/localstack.hcl`.
5. Runs optional import script (if present).
6. Runs Terraform `apply` with `tfvars/localstack.tfvars`.

Deployment mode:

- Default is `db-only` (applies only `module.db`, enough for `snackpersona` app).
- Full stack is possible with:

```bash
./scripts/deploy_localstack_terraform.sh global full
```

Note: full mode may fail on LocalStack Community if services like ECR/ECS are not available.

## 3. Verify DynamoDB table exists

```bash
aws --endpoint-url=http://localhost:4566 \
  --region us-east-1 \
  dynamodb list-tables
```

Expected table:

- `SnackTable`

## 4. Run snackpersona with LocalStack

```bash
export AWS_ENDPOINT_URL=http://localhost:4566
export AWS_REGION=us-east-1
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export DYNAMODB_TABLE=SnackTable

PYTHONPATH=apps/persona/src python -m snackpersona.main --llm mock --generations 1 --pop_size 2 --no-viz
```

The app now runs startup preflight checks for:

- DynamoDB endpoint reachability
- DynamoDB table availability
- Web search/crawl connectivity
- LLM connectivity (or mock skip)

If any check fails, startup exits with code `1`.
