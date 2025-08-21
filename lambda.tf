data "aws_ecr_repository" "put_neo_data" {
  name = "put_neo_data"
}

data "aws_ecr_repository" "get_neo_data" {
  name = "get_neo_data"
}

### Put NEO data

resource "aws_lambda_function" "put-neo-data" {
  function_name = "${local.prefix}-put-neo-data"
  role          = module.iam.put_function_iam_role
  package_type  = "Image"
  image_uri     = "${data.aws_ecr_repository.put_neo_data.repository_url}:latest"
  timeout       = 10

  environment {
    variables = {
      API_KEY_SECRET_ID    = var.api_key_secretsmanager_name
      DYNAMO_DB_TABLE_NAME = aws_dynamodb_table.nasa-neo.name
      REGION               = data.aws_region.current.name
    }
  }
}

### Permissions to invoke Put NEO Function from Get NEO Function

resource "aws_lambda_permission" "put_neo_invoke" {
  statement_id  = "AllowLambdaInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.put-neo-data.function_name
  principal     = "lambda.amazonaws.com"
  source_arn    = aws_lambda_function.get-neo-data.arn
}

### Get NEO data

resource "aws_lambda_function" "get-neo-data" {
  function_name = "${local.prefix}-get-neo-data"
  role          = module.iam.get_function_iam_role
  package_type  = "Image"
  image_uri     = "${data.aws_ecr_repository.get_neo_data.repository_url}:latest"
  timeout       = 10

  environment {
    variables = {
      BUCKET_NAME            = aws_s3_bucket.app.id,
      DYNAMO_DB_TABLE_NAME   = aws_dynamodb_table.nasa-neo.name,
      GLOBAL_SECONDARY_INDEX = local.global_secondary_index,
      LAMBDA_FUNCTION_PUT    = aws_lambda_function.put-neo-data.function_name
      REGION                 = data.aws_region.current.name
    }
  }
}