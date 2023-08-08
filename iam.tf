### Lambda Roles

### Put NEO data

resource "aws_iam_role" "lambda-put-neo-data" {
  name = "${local.prefix}-lambda-put-neo-data-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "AssumeLambdaRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda-put-neo-data-policy" {
  name   = "${local.prefix}-lambda-put-neo-data-policy"
  policy = data.template_file.lambda-put-neo-data-role-policy.rendered
}

resource "aws_iam_role_policy_attachment" "lambda-put-neo-data-role-attachment" {
  role       = aws_iam_role.lambda-put-neo-data.name
  policy_arn = aws_iam_policy.lambda-put-neo-data-policy.arn
}

data "template_file" "lambda-put-neo-data-role-policy" {
  template = file("./templates/iam/lambda-put-neo-data.json.tpl")
  vars = {
    region                 = data.aws_region.current.name,
    account_id             = data.aws_caller_identity.current.account_id,
    bucket_name            = aws_s3_bucket.app.id,
    dynamodb_table         = aws_dynamodb_table.nasa-dart-neo.name,
    api_key_parameter_name = "nasa-api-key",
    log_group              = aws_cloudwatch_log_group.lambda-put-neo-data.name
  }
}

### Get NEO data

resource "aws_iam_role" "lambda-get-neo-data" {
  name = "${local.prefix}-lambda-get-neo-data-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "AssumeLambdaRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda-get-neo-data-policy" {
  name   = "${local.prefix}-lambda-get-neo-data-policy"
  policy = data.template_file.lambda-get-neo-data-role-policy.rendered
}

resource "aws_iam_role_policy_attachment" "lambda-get-neo-data-role-attachment" {
  role       = aws_iam_role.lambda-get-neo-data.name
  policy_arn = aws_iam_policy.lambda-get-neo-data-policy.arn
}

data "template_file" "lambda-get-neo-data-role-policy" {
  template = file("./templates/iam/lambda-get-neo-data.json.tpl")
  vars = {
    region         = data.aws_region.current.name,
    account_id     = data.aws_caller_identity.current.account_id,
    dynamodb_table = aws_dynamodb_table.nasa-dart-neo.name,
    function_name  = aws_lambda_function.put-neo-data.function_name,
    log_group      = aws_cloudwatch_log_group.lambda-get-neo-data.name
  }
}

### EventBridge

resource "aws_iam_role" "eventbridge-schedule" {
  name = "${local.prefix}-eventbridge-schedule"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "AssumeLambdaRole"
        Principal = {
          Service = "scheduler.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "eventbridge-schedule-policy" {
  name   = "${local.prefix}-eventbridge-schedule-policy"
  policy = data.template_file.eventbridge-schedule-role-policy.rendered
}

resource "aws_iam_role_policy_attachment" "eventbridge-schedule-role-attachment" {
  role       = aws_iam_role.eventbridge-schedule.name
  policy_arn = aws_iam_policy.eventbridge-schedule-policy.arn
}

data "template_file" "eventbridge-schedule-role-policy" {
  template = file("./templates/iam/eventbridge-schedule.json.tpl")
  vars = {
    region         = data.aws_region.current.name,
    account_id     = data.aws_caller_identity.current.account_id
    function_name  = aws_lambda_function.put-neo-data.function_name
  }
}