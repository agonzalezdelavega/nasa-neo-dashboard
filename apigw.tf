resource "aws_api_gateway_rest_api" "api" {
  name = "${local.prefix}-api"
  endpoint_configuration {
    types = ["EDGE"]
  }
}

### Resources

resource "aws_api_gateway_resource" "neo-dashboard" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "dashboard"
}

resource "aws_api_gateway_resource" "neos" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.neo-dashboard.id
  path_part   = "{date}"
}

### GET Method

resource "aws_api_gateway_method" "neos-get" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.neos.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.neos.id
  http_method             = aws_api_gateway_method.neos-get.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.get-neo-data.invoke_arn
  passthrough_behavior    = "WHEN_NO_TEMPLATES"

  request_templates = {
    "application/json" = <<EOF
#set($inputRoot = $input.path('$'))
{
    "date": "$input.params('date')"
}
EOF
  }

  depends_on = [ 
    aws_api_gateway_method.neos-get
  ]

}

resource "aws_api_gateway_integration_response" "get-integration-response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.neos.id
  http_method = aws_api_gateway_method.neos-get.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  depends_on = [
    aws_api_gateway_integration.get_integration
  ]
}

resource "aws_api_gateway_method_response" "get-response_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.neos.id
  http_method = aws_api_gateway_method.neos-get.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
  response_models = {
    "application/json" = aws_api_gateway_model.neos.name
  }

  depends_on = [ 
    aws_api_gateway_method.neos-get
   ]

}

### Enable CORS

module "cors" {
  source  = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"

  api_id          = aws_api_gateway_rest_api.api.id
  api_resource_id = aws_api_gateway_resource.neos.id
}

### Models

resource "aws_api_gateway_model" "neos" {
  rest_api_id  = aws_api_gateway_rest_api.api.id
  name         = "neos"
  content_type = "application/json"

  schema = file("./templates/models/neos.json")
}

### API Deployment

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  depends_on = [ 
    aws_api_gateway_method.neos-get,
    aws_api_gateway_integration.get_integration,
    aws_api_gateway_integration_response.get-integration-response
   ]
}

resource "aws_api_gateway_stage" "api_deployment_stage" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "prod"

  provisioner "local-exec" {
    working_dir = "./site/"
    command     = <<-EOF
aws apigateway get-sdk --rest-api-id ${aws_api_gateway_rest_api.api.id} \
  --stage-name ${aws_api_gateway_stage.api_deployment_stage.stage_name} \
  --sdk-type javascript apiGateway-js-sdk.zip && \
  unzip -of apiGateway-js-sdk.zip -d apiGateway-js-sdk
EOF
  }

  depends_on = [
    aws_api_gateway_deployment.deployment
  ]

}

### Lambda permissions

resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get-neo-data.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*"
}
