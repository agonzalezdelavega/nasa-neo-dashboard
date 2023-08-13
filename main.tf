provider "aws" {
  region = "us-east-2"
}

provider "aws" {
  region = "us-east-1"
  alias = "us-east-1"
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

locals {
  prefix                 = "nasa-neo"
  global_secondary_index = "SearchByDate"
  domain_prefix          = "neo" 
}

# DNS name from Route53
variable "dns_zone_name" {
  type = string
}

# Secret Name for Lambda to retreive NASA API key
variable "api_key_secretsmanager_name" {
  type = string
}

variable "api_key_kms_key" {
  type = string
}