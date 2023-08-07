### Lambda Log Group

resource "aws_cloudwatch_log_group" "lambda_get-neo-data" {
  name              = "${local.prefix}-${aws_lambda_function.get-neo-data.function_name}"
  retention_in_days = 14
}