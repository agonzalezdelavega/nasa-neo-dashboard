output "put_function_iam_role" {
    value = aws_iam_role.lambda-put-neo-data.arn
}

output "get_function_iam_role" {
    value = aws_iam_role.lambda_get_neo_data.arn
}