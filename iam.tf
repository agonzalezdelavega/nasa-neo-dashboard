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

resource "aws_kms_key" "api-kms-key" {}

data "aws_secretsmanager_secret" "api-key" {
  name = var.api_key_secretsmanager_name
}

data "template_file" "lambda-put-neo-data-role-policy" {
  template = file("./templates/iam/lambda-put-neo-data.json.tpl")
  vars = {
    region                 = data.aws_region.current.name,
    account_id             = data.aws_caller_identity.current.account_id,
    bucket_name            = aws_s3_bucket.app.id,
    dynamodb_table         = aws_dynamodb_table.nasa-neo.arn,
    kms_key_arn            = aws_kms_key.api-kms-key.arn,
    api_key_arn            = data.aws_secretsmanager_secret.api-key.arn,
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
    dynamodb_table = aws_dynamodb_table.nasa-neo.name,
    function_name  = aws_lambda_function.put-neo-data.function_name,
    log_group      = aws_cloudwatch_log_group.lambda-get-neo-data.name
  }
}