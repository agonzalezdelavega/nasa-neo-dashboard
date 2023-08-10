resource "aws_dynamodb_table" "nasa-neo" {
  name           = "${local.prefix}-neos"
  hash_key       = "neo_id"
  range_key      = "close_approach_date"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1

  attribute {
    name = "neo_id"
    type = "N"
  }
  attribute {
    name = "close_approach_date"
    type = "S"
  }

  ttl {
    attribute_name = "uploaded_on"
    enabled        = true
  }

  global_secondary_index {
    name            = local.global_secondary_index
    hash_key        = "close_approach_date"
    write_capacity  = 1
    read_capacity   = 1
    projection_type = "ALL"
  }
}
