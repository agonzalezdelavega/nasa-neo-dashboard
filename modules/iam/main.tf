### Lambda Roles

### Put NEO data

resource "aws_iam_role" "lambda-put-neo-data" {
  name = "${var.prefix}-lambda-put-neo-data-role"
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
  name   = "${var.prefix}-lambda-put-neo-data-policy"
  policy = data.template_file.lambda-put-neo-data-role-policy.rendered
}

resource "aws_iam_role_policy_attachment" "lambda-put-neo-data-role-attachment" {
  role       = aws_iam_role.lambda-put-neo-data.name
  policy_arn = aws_iam_policy.lambda-put-neo-data-policy.arn
}

resource "aws_kms_key" "api-kms-key" {}

data "template_file" "lambda-put-neo-data-role-policy" {
  template = file("./templates/iam/lambda-put-neo-data.json.tpl")
  vars = {
    region         = var.region,
    account_id     = var.account_id,
    bucket_name    = var.bucket_name,
    dynamodb_table = var.dynamodb_table,
    kms_key_arn    = aws_kms_key.api-kms-key.arn,
    api_key_arn    = var.api_key_arn,
    # log_group      = var.put_function_log_group
    # filesystem_arn = var.file_system_arn
  }
}

### Get NEO data

resource "aws_iam_role" "lambda_get_neo_data" {
  name = "${var.prefix}-lambda_get_neo_data-role"
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

resource "aws_iam_policy" "lambda_get_neo_data-policy" {
  name   = "${var.prefix}-lambda_get_neo_data-policy"
  policy = data.template_file.lambda_get_neo_data-role-policy.rendered
}

resource "aws_iam_role_policy_attachment" "lambda_get_neo_data-role-attachment" {
  role       = aws_iam_role.lambda_get_neo_data.name
  policy_arn = aws_iam_policy.lambda_get_neo_data-policy.arn
}

data "template_file" "lambda_get_neo_data-role-policy" {
  template = file("./templates/iam/lambda-get-neo-data.json.tpl")
  vars = {
    region         = var.region,
    account_id     = var.account_id,
    dynamodb_table = var.dynamodb_table,
    function_name  = var.put_function_name
    # log_group      = var.get_function_log_group,
    # filesystem_arn = var.file_system_arn
  }
}