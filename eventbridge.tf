resource "aws_cloudwatch_event_rule" "trigger_put_daily" {
  name                = "${local.prefix}-trigger-put-lambda-daily"
  schedule_expression = "cron(0 5 * * ? *)"
}

resource "aws_cloudwatch_event_target" "trigger_put_daily" {
  arn  = aws_lambda_function.put-neo-data.arn
  rule = aws_cloudwatch_event_rule.trigger_put_daily.name
}

### Lambda permissions

resource "aws_lambda_permission" "eventbridge_lambda_permission" {
  statement_id  = "AllowAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.put-neo-data.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.trigger_put_daily.arn
}
