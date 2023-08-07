resource "aws_lambda_function" "get-neo-data" {
  filename      = "./lambda/get-neo-data.zip"
  function_name = "${local.prefix}-get-neo-data"
  role          = aws_iam_role.lambda.arn
  handler       = "index.handler"
  runtime       = "python3.9"

  layers = [aws_lambda_layer_version.get-neo-data.arn]

  environment {
    variables = {
      BUCKET_NAME          = aws_s3_bucket.app.id
      DYNAMO_DB_TABLE_NAME = aws_dynamodb_table.nasa-dart-neo.name
    }
  }
}

resource "aws_lambda_layer_version" "get-neo-data" {
  filename   = "./lambda/layers/get-neo-data/get-neo-data.zip"
  layer_name = "get-neo-data"

  compatible_runtimes = ["python3.9"]
}

resource "aws_lambda_invocation" "invoke-get-neo-data" {
  function_name = aws_lambda_function.get-neo-data.function_name

  input = jsonencode({
    date = formatdate("YYYY-MM-DD", timestamp())
  })
}