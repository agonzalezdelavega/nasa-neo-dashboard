### Put NEO data

resource "aws_lambda_function" "put-neo-data" {
  filename      = data.archive_file.put-neo-data-function-code.output_path
  function_name = "${local.prefix}-put-neo-data"
  role          = aws_iam_role.lambda-put-neo-data.arn
  handler       = "index.handler"
  runtime       = "python3.9"
  layers        = [
    aws_lambda_layer_version.pandas.arn,
    aws_lambda_layer_version.put-neo-data-requests.arn
  ]
  timeout       = 10

  environment {
    variables = {
      API_KEY_SECRET_ID    = var.api_key_secretsmanager_name
      DYNAMO_DB_TABLE_NAME = aws_dynamodb_table.nasa-neo.name
      REGION               = data.aws_region.current.name
    }
  }
}

data "archive_file" "put-neo-data-function-code" {
  type        = "zip"
  source_file = "./lambda/put-neo-data/index.py"
  output_path = "./lambda/put-neo-data.zip"
}

### Get NEO data

resource "aws_lambda_function" "get-neo-data" {
  filename      = data.archive_file.get-neo-data-function-code.output_path
  function_name = "${local.prefix}-get-neo-data"
  role          = aws_iam_role.lambda-get-neo-data.arn
  handler       = "index.handler"
  runtime       = "python3.9"
  layers        = [
    aws_lambda_layer_version.pandas.arn
  ]
  timeout       = 10

  environment {
    variables = {
      BUCKET_NAME            = aws_s3_bucket.app.id,
      DYNAMO_DB_TABLE_NAME   = aws_dynamodb_table.nasa-neo.name,
      GLOBAL_SECONDARY_INDEX = local.global_secondary_index,
      LAMBDA_FUNCTION_PUT    = aws_lambda_function.put-neo-data.function_name
      REGION                 = data.  aws_region.current.name
    }
  }
}

data "archive_file" "get-neo-data-function-code" {
  type        = "zip"
  source_file = "./lambda/get-neo-data/index.py"
  output_path = "./lambda/get-neo-data.zip"
}

### Layers

resource "aws_lambda_layer_version" "pandas" {
  filename            = "./lambda/layers/common/pandas-layer.zip"
  layer_name          = "pandas-layer"
  compatible_runtimes = ["python3.9"]
}

resource "aws_lambda_layer_version" "put-neo-data-requests" {
  filename            = "./lambda/layers/put-neo-data/put-neo-data.zip"
  layer_name          = "put-neo-data"
  compatible_runtimes = ["python3.9"]
}
