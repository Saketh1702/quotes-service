```hcl
provider "aws" {
  region = var.aws_region
}

# API Gateway
resource "aws_api_gateway_rest_api" "quotes_api" {
  name        = "${var.environment}-quotes-api"
  description = "API Gateway for Quotes Service"
}

# API Gateway Resources
resource "aws_api_gateway_resource" "quotes" {
  rest_api_id = aws_api_gateway_rest_api.quotes_api.id
  parent_id   = aws_api_gateway_rest_api.quotes_api.root_resource_id
  path_part   = "quotes"
}

# GET Method
resource "aws_api_gateway_method" "get_quote" {
  rest_api_id   = aws_api_gateway_rest_api.quotes_api.id
  resource_id   = aws_api_gateway_resource.quotes.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_quote" {
  rest_api_id = aws_api_gateway_rest_api.quotes_api.id
  resource_id = aws_api_gateway_resource.quotes.id
  http_method = aws_api_gateway_method.get_quote.http_method
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.get_quote.invoke_arn
  integration_http_method = "POST"
}

# POST Method
resource "aws_api_gateway_method" "put_quote" {
  rest_api_id   = aws_api_gateway_rest_api.quotes_api.id
  resource_id   = aws_api_gateway_resource.quotes.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "put_quote" {
  rest_api_id = aws_api_gateway_rest_api.quotes_api.id
  resource_id = aws_api_gateway_resource.quotes.id
  http_method = aws_api_gateway_method.put_quote.http_method
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.put_quote.invoke_arn
  integration_http_method = "POST"
}

# Deployment
resource "aws_api_gateway_deployment" "quotes" {
  rest_api_id = aws_api_gateway_rest_api.quotes_api.id
  depends_on = [
    aws_api_gateway_integration.get_quote,
    aws_api_gateway_integration.put_quote
  ]
}

# Stage
resource "aws_api_gateway_stage" "quotes" {
  deployment_id = aws_api_gateway_deployment.quotes.id
  rest_api_id   = aws_api_gateway_rest_api.quotes_api.id
  stage_name    = var.environment
}

# DynamoDB Table
resource "aws_dynamodb_table" "quotes_table" {
  name           = "${var.environment}-quotes"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "quote"
  
  attribute {
    name = "quote"
    type = "S"
  }

  tags = {
    Environment = var.environment
    Project     = "quotes-service"
  }
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${var.environment}-quotes-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# CloudWatch Logs policy for Lambda
resource "aws_iam_role_policy" "lambda_cloudwatch_policy" {
  name = "${var.environment}-lambda-cloudwatch-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
        Effect = "Allow"
      }
    ]
  })
}

# DynamoDB policy for Lambda
resource "aws_iam_role_policy" "lambda_dynamodb_policy" {
  name = "${var.environment}-lambda-dynamodb-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:Scan"
        ]
        Resource = aws_dynamodb_table.quotes_table.arn
        Effect = "Allow"
      }
    ]
  })
}

# API Gateway Role
resource "aws_iam_role" "api_gateway_role" {
  name = "${var.environment}-api-gateway-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })
}

# API Gateway CloudWatch Logs Policy
resource "aws_iam_role_policy" "api_gateway_cloudwatch_policy" {
  name = "${var.environment}-api-gateway-cloudwatch-policy"
  role = aws_iam_role.api_gateway_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents",
          "logs:PutLogEvents",
          "logs:FilterLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

# Lambda Functions
resource "aws_lambda_function" "get_quote" {
  filename         = "../src/functions/get_quote.zip"
  function_name    = "${var.environment}-get-quote"
  role            = aws_iam_role.lambda_role.arn
  handler         = "lambda_function.lambda_handler"
  runtime         = "python3.9"

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.quotes_table.name
    }
  }
}

resource "aws_lambda_function" "put_quote" {
  filename         = "../src/functions/put_quote.zip"
  function_name    = "${var.environment}-put-quote"
  role            = aws_iam_role.lambda_role.arn
  handler         = "lambda_function.lambda_handler"
  runtime         = "python3.9"

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.quotes_table.name
    }
  }
}
```