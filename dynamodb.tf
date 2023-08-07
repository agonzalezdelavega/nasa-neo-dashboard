resource "aws_dynamodb_table" "nasa-dart-neo" {
  name           = "${local.prefix}-neos"
  hash_key       = "neo_id"
  range_key      = "date"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1

  attribute {
    name = "neo_id"
    type = "N"
  }
  attribute {
    name = "date"
    type = "S"
  }

  ttl {
    attribute_name = "uploaded_on"
    enabled =  false
  }
}
