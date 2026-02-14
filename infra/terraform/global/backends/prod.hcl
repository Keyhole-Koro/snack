bucket         = "terraform-state-prod-snack-12345"
key            = "snack/terraform.tfstate"
region         = "us-east-1"
encrypt        = true
dynamodb_table = "terraform-lock"
