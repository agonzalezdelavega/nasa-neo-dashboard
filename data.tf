data "aws_secretsmanager_secret" "api-key" {
  name = var.api_key_secretsmanager_name
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}
