### Put NEO data

resource "aws_lambda_function" "put-neo-data" {
  filename      = data.archive_file.put-neo-data-function-code.output_path
  function_name = "${local.prefix}-put-neo-data"
  role          = aws_iam_role.lambda-put-neo-data.arn
  handler       = "index.handler"
  runtime       = "python3.9"
  layers        = [aws_lambda_layer_version.put-neo-data.arn]
  timeout       = 10

  environment {
    variables = {
      BUCKET_NAME          = aws_s3_bucket.app.id
      DYNAMO_DB_TABLE_NAME = aws_dynamodb_table.nasa-dart-neo.name
    }
  }
}

data "archive_file" "put-neo-data-function-code" {
  type        = "zip"
  source_file = "./lambda/put-neo-data/index.py"
  output_path = "./lambda/put-neo-data.zip"
}

resource "aws_lambda_layer_version" "put-neo-data" {
  filename            = "./lambda/layers/put-neo-data/put-neo-data.zip"
  layer_name          = "put-neo-data"
  compatible_runtimes = ["python3.9"]
}

### Get NEO data

resource "aws_lambda_function" "get-neo-data" {
  filename      = data.archive_file.get-neo-data-function-code.output_path
  function_name = "${local.prefix}-get-neo-data"
  role          = aws_iam_role.lambda-get-neo-data.arn
  handler       = "index.handler"
  runtime       = "python3.9"
  layers        = [aws_lambda_layer_version.get-neo-data.arn]
  timeout       = 10

  environment {
    variables = {
      BUCKET_NAME            = aws_s3_bucket.app.id,
      DYNAMO_DB_TABLE_NAME   = aws_dynamodb_table.nasa-dart-neo.name,
      GLOBAL_SECONDARY_INDEX = local.global_secondary_index,
      LAMBDA_FUNCTION_PUT    = aws_lambda_function.put-neo-data.function_name
    }
  }
}

data "archive_file" "get-neo-data-function-code" {
  type        = "zip"
  source_file = "./lambda/get-neo-data/index.py"
  output_path = "./lambda/get-neo-data.zip"
}

resource "aws_lambda_layer_version" "get-neo-data" {
  filename            = "./lambda/layers/get-neo-data/get-neo-data.zip"
  layer_name          = "get-neo-data"
  compatible_runtimes = ["python3.9"]
}
