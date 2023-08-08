### Lambda Log Groups

### Put NEO data

resource "aws_cloudwatch_log_group" "lambda-put-neo-data" {
  name              = "/aws/lambda/${aws_lambda_function.put-neo-data.function_name}"
  retention_in_days = 14
}

### Get NEO data

resource "aws_cloudwatch_log_group" "lambda-get-neo-data" {
  name              = "/aws/lambda/${aws_lambda_function.get-neo-data.function_name}"
  retention_in_days = 14
}