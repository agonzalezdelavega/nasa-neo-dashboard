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
}

variable "dns_zone_name" {}