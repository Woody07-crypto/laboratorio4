output "clientes_url" {
  value = "${aws_api_gateway_deployment.api_deployment.invoke_url}/clientes"
}

output "transferencias_url" {
  value = "${aws_api_gateway_deployment.api_deployment.invoke_url}/transferencias"
}
