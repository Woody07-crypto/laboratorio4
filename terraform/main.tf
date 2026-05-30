resource "aws_dynamodb_table" "clientes" {

  name         = "clientes"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_dynamodb_table" "cuentas" {

  name         = "cuentas"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "cuenta_id"

  attribute {
    name = "cuenta_id"
    type = "S"
  }
}

resource "aws_dynamodb_table" "transferencias" {

  name         = "transferencias"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "transferencia_id"

  attribute {
    name = "transferencia_id"
    type = "S"
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "dynamodb_policy" {
  name = "dynamodb_policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "dynamodb:*"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_lambda_function" "crear_cliente" {
  function_name    = "crear_cliente"
  runtime          = "python3.11"
  handler          = "main.lambda_handler"
  filename         = "../lambdas/crear_cliente/lambda.zip"
  source_code_hash = filebase64sha256("../lambdas/crear_cliente/lambda.zip")
  role             = aws_iam_role.lambda_role.arn
}

resource "aws_lambda_function" "realizar_transferencia" {
  function_name    = "realizar_transferencia"
  runtime          = "python3.11"
  handler          = "main.lambda_handler"
  filename         = "../lambdas/realizar_transferencia/lambda.zip"
  source_code_hash = filebase64sha256("../lambdas/realizar_transferencia/lambda.zip")
  role             = aws_iam_role.lambda_role.arn
}

resource "aws_api_gateway_rest_api" "api" {
  name = "laboratorio-api"
}

resource "aws_api_gateway_resource" "clientes_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "clientes"
}

resource "aws_api_gateway_method" "clientes_post" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.clientes_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "clientes_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.clientes_resource.id
  http_method             = aws_api_gateway_method.clientes_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.crear_cliente.invoke_arn
}

resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.crear_cliente.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_api_gateway_resource" "transferencias_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "transferencias"
}

resource "aws_api_gateway_method" "transferencias_post" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.transferencias_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "transferencias_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.transferencias_resource.id
  http_method             = aws_api_gateway_method.transferencias_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.realizar_transferencia.invoke_arn
}

resource "aws_lambda_permission" "transferencias_permission" {
  statement_id  = "AllowTransferenciasInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.realizar_transferencia.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [
    aws_api_gateway_integration.clientes_integration,
    aws_api_gateway_integration.transferencias_integration
  ]

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.clientes_resource.id,
      aws_api_gateway_resource.transferencias_resource.id
    ]))
  }

  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "dev"
}
