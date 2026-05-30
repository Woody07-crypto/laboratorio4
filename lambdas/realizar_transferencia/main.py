import json
import boto3
import uuid
from datetime import datetime

dynamodb = boto3.resource('dynamodb')

tabla = dynamodb.Table('transferencias')

def lambda_handler(event, context):

    try:

        print("===== NUEVA TRANSFERENCIA =====")

        body = json.loads(event['body'])

        transferencia = {
            "transferencia_id": str(uuid.uuid4()),
            "cuenta_origen": body['cuenta_origen'],
            "cuenta_destino": body['cuenta_destino'],
            "monto": body['monto'],
            "fecha_transferencia": datetime.utcnow().isoformat()
        }

        tabla.put_item(Item=transferencia)

        print(f"Transferencia almacenada: {transferencia}")

        return {
            'statusCode': 200,
            'body': json.dumps(transferencia)
        }

    except Exception as e:

        print(f"ERROR: {str(e)}")

        return {
            'statusCode': 500,
            'body': json.dumps({
                'mensaje': 'Error en transferencia'
            })
        }
