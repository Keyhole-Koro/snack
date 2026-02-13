terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {}
}

provider "aws" {
  region = var.region
}

module "db" {
  source     = "./service/db"
  table_name = var.table_name
}

module "frontend" {
  source      = "./service/frontend"
  bucket_name = var.bucket_name
}

module "simulation" {
  source     = "./service/simulation"
  env        = var.env
  table_name = module.db.table_name
  table_arn  = module.db.table_arn
}

module "backend" {
  source     = "./service/backend"
  env        = var.env
  table_name = module.db.table_name
  table_arn  = module.db.table_arn
}

output "api_endpoint" {
  value = module.backend.api_endpoint
}

output "frontend_bucket" {
  value = module.frontend.bucket_name
}

output "cloudfront_domain" {
  value = module.frontend.cloudfront_domain
}
