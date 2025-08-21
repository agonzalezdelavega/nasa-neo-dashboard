module "iam" {
  source = "./modules/iam"

  prefix            = local.prefix
  region            = data.aws_region.current.name
  account_id        = data.aws_caller_identity.current.account_id
  api_key_arn       = data.aws_secretsmanager_secret.api-key.arn
  dynamodb_table    = aws_dynamodb_table.nasa-neo.arn
  put_function_name = "${local.prefix}-put-neo-data"
  bucket_name       = aws_s3_bucket.app.id
}
