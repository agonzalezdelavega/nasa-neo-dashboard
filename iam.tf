### Lambda Role

resource "aws_iam_role" "lambda" {
  name = "${local.prefix}-lambda-role"
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

resource "aws_iam_policy" "lambda" {
  name   = "${local.prefix}-lambda-policy"
  policy = data.template_file.lambda_role_policy.rendered
}

resource "aws_iam_role_policy_attachment" "lambda-role-attachment" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda.arn
}

data "template_file" "lambda_role_policy" {
  template = file("./templates/iam/lambda-role-policy.json.tpl")
  vars = {
    bucket_name = aws_s3_bucket.app.id
  }
}