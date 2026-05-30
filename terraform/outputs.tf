output "crear_cliente_lambda_arn" {
  description = "ARN of the crear_cliente Lambda function"
  value       = aws_lambda_function.crear_cliente.arn
}

output "realizar_transferencia_lambda_arn" {
  description = "ARN of the realizar_transferencia Lambda function"
  value       = aws_lambda_function.realizar_transferencia.arn
}

output "clientes_url" {

  value = "${aws_api_gateway_deployment.api_deployment.invoke_url}/clientes"
}

output "transferencias_url" {

  value = "${aws_api_gateway_deployment.api_deployment.invoke_url}/transferencias"
}
