# resource "aws_api_gateway_rest_api" "api" {
#   name = "${local.prefix}-app-api"
#   endpoint_configuration {
#     types = ["EDGE"]
#   }
# }

# ### Enable proxy

# resource "aws_api_gateway_resource" "api_resource" {
#   rest_api_id = aws_api_gateway_rest_api.api.id
#   parent_id   = aws_api_gateway_rest_api.api.root_resource_id
#   path_part   = "{proxy+}"
# }

# resource "aws_api_gateway_method" "any-method" {
#   rest_api_id   = aws_api_gateway_rest_api.api.id
#   resource_id   = aws_api_gateway_resource.api_resource.id
#   http_method   = "ANY"
#   authorization = "NONE"
# }

# resource "aws_api_gateway_integration" "api_integration" {
#   rest_api_id             = aws_api_gateway_rest_api.api.id
#   resource_id             = aws_api_gateway_resource.api_resource.id
#   http_method             = aws_api_gateway_method.any-method.http_method
#   integration_http_method = "POST"
#   type                    = "AWS_PROXY"
#   passthrough_behavior    = "WHEN_NO_MATCH"
#   uri                     = aws_lambda_function.app_lambda.invoke_arn
# }

# ### Enable CORS

# module "cors" {
#   source = "squidfunk/api-gateway-enable-cors/aws"
#   version = "0.3.3"

#   api_id          = aws_api_gateway_rest_api.api.id
#   api_resource_id = aws_api_gateway_resource.api_resource.id
# }

# ### API Deployment

# resource "aws_api_gateway_deployment" "deployment" {
#   rest_api_id = aws_api_gateway_rest_api.api.id
# }

# resource "aws_api_gateway_stage" "api_deployment_stage" {
#   deployment_id = aws_api_gateway_deployment.deployment.id
#   rest_api_id   = aws_api_gateway_rest_api.api.id
#   stage_name    = "serverless-app"
# }

# ### Lambda permissions

# resource "aws_lambda_permission" "lambda_permission" {
#   statement_id  = "AllowAPIInvoke"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.app_lambda.function_name
#   principal     = "apigateway.amazonaws.com"
#   source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*/*"
# }


# ### CORS Options
# # ✔ Create OPTIONS method
# # ✔ Add 200 Method Response with Empty Response Model to OPTIONS method
# # ✔ Add Mock Integration to OPTIONS method
# # ✔ Add 200 Integration Response to OPTIONS method
# # ✔ Add Access-Control-Allow-Headers, Access-Control-Allow-Methods, Access-Control-Allow-Origin Method Response Headers to OPTIONS method
# # ✔ Add Access-Control-Allow-Headers, Access-Control-Allow-Methods, Access-Control-Allow-Origin Integration Response Header Mappings to OPTIONS method
# # ✔ Add Access-Control-Allow-Origin Method Response Header to GET method
# # ✔ Add Access-Control-Allow-Origin Integration Response Header Mapping to GET method