import json
import boto3
import uuid
from datetime import datetime

dynamodb = boto3.resource('dynamodb')

tabla = dynamodb.Table('clientes')


def lambda_handler(event, context):

    try:

        print("===== NUEVO REQUEST =====")

        body = json.loads(event['body'])

        if 'nombre' not in body:
            return {
                'statusCode': 400,
                'body': json.dumps({
                    'mensaje': 'El nombre es obligatorio'
                })
            }

        if 'correo' not in body:
            return {
                'statusCode': 400,
                'body': json.dumps({
                    'mensaje': 'El correo es obligatorio'
                })
            }

        if body['nombre'] == "":
            return {
                'statusCode': 400,
                'body': json.dumps({
                    'mensaje': 'Nombre vacío'
                })
            }

        if body['correo'] == "":
            return {
                'statusCode': 400,
                'body': json.dumps({
                    'mensaje': 'Correo vacío'
                })
            }

        cliente = {
            "id": str(uuid.uuid4()),
            "nombre": body['nombre'],
            "correo": body['correo'],
            "fecha_creacion": datetime.utcnow().isoformat()
        }

        tabla.put_item(Item=cliente)

        print(f"Cliente almacenado: {cliente}")

        return {
            'statusCode': 200,
            'body': json.dumps(cliente)
        }

    except Exception as e:

        print(f"ERROR: {str(e)}")

        return {
            'statusCode': 500,
            'body': json.dumps({
                'mensaje': 'Error interno'
            })
        }
