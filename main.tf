provider "aws" {
  region = "eu-west-1"
}

provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"
}

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