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
