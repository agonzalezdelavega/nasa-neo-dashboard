provider "aws" {
  region = "us-east-2"
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

locals {
  prefix = "nasa-dart"
}