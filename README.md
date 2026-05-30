# Laboratorio 4 — Backend Cloud-Native con AWS Lambda y DynamoDB

Backend serverless para una institución bancaria, implementado con **Terraform**, **AWS Lambda**, **DynamoDB**, **API Gateway** y **Python**. Toda la infraestructura se provisiona exclusivamente con Terraform (sin crear ni modificar recursos manualmente en la consola de AWS).

## Objetivo

Desarrollar un backend serverless funcional orientado a:

- Desarrollo backend en la nube
- Integración de servicios AWS
- Debugging y manejo de errores
- Resolución de problemas reales en entornos serverless

## Escenario

El sistema permite:

- Registrar clientes
- Realizar transferencias entre cuentas
- Almacenar historial de movimientos en DynamoDB

> La tabla `cuentas` queda provisionada en Terraform para extender el escenario bancario (consulta de cuentas y validación de saldo) en iteraciones futuras.

## Tecnologías

| Tecnología | Uso |
|---|---|
| **Terraform** | Infraestructura como código (IaC) |
| **AWS Lambda** | Lógica de negocio serverless (`crear_cliente`, `realizar_transferencia`) |
| **DynamoDB** | Persistencia de clientes, cuentas y transferencias |
| **API Gateway** | Exposición REST de los endpoints |
| **CloudWatch** | Logs y observabilidad de las Lambdas |
| **Python 3.9** | Runtime de las funciones Lambda |
| **boto3** | SDK de AWS para acceso a DynamoDB |

## Arquitectura

```
Cliente (Postman / curl)
        │
        ▼
┌───────────────────┐
│   API Gateway     │  POST /clientes
│  laboratorio-api  │  POST /transferencias
└─────────┬─────────┘
          │ AWS_PROXY
    ┌─────┴─────┐
    ▼           ▼
┌─────────┐ ┌─────────────────────┐
│ crear_  │ │ realizar_           │
│ cliente │ │ transferencia       │
└────┬────┘ └──────────┬──────────┘
     │                 │
     ▼                 ▼
┌─────────┐      ┌──────────────┐
│ clientes│      │transferencias│
│ (Dynamo)│      │   (Dynamo)   │
└─────────┘      └──────────────┘
     │
     └── cuentas (DynamoDB, provisionada)
```

## Estructura del proyecto

```
laboratorio4/
├── terraform/
│   ├── provider.tf      # Provider AWS y región
│   ├── variables.tf     # Variable aws_region (us-east-2)
│   ├── main.tf          # DynamoDB, IAM, Lambda, API Gateway
│   └── outputs.tf       # URLs de los endpoints
├── lambdas/
│   ├── crear_cliente/
│   │   ├── main.py
│   │   └── requirements.txt
│   └── realizar_transferencia/
│       ├── main.py
│       └── requirements.txt
└── README.md
```

Los archivos `lambda.zip` se generan automáticamente al ejecutar `terraform plan/apply` mediante bloques `archive_file` en `main.tf`. No es necesario empaquetar manualmente salvo que prefieras hacerlo por separado.

## Recursos creados con Terraform

| Recurso | Nombre / detalle |
|---|---|
| Tablas DynamoDB | `clientes`, `cuentas`, `transferencias` (PAY_PER_REQUEST) |
| Funciones Lambda | `crear_cliente`, `realizar_transferencia` |
| API REST | `laboratorio-api` (stage `dev`) |
| IAM Role | `lambda_role` con permisos de logs y DynamoDB |
| Endpoints | `POST /clientes`, `POST /transferencias` |

## Requisitos

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.0
- [AWS CLI](https://aws.amazon.com/cli/) configurado (`aws configure`)
- Python 3.x (opcional, para desarrollo local de las Lambdas)
- [Postman](https://www.postman.com/) o `curl` para pruebas

## Configuración de AWS

Configura credenciales con la región del laboratorio:

```bash
aws configure
# Default region: us-east-2
```

Si usas el perfil de un compañero (cuenta compartida del curso):

```powershell
aws configure --profile companero
$env:AWS_PROFILE = "companero"
```

## Despliegue

```bash
git clone https://github.com/Woody07-crypto/laboratorio4.git
cd laboratorio4/terraform

terraform init
terraform fmt
terraform plan
terraform apply
```

Confirma con `yes` cuando Terraform lo solicite. Al finalizar, copia los outputs:

```bash
terraform output clientes_url
terraform output transferencias_url
```

Ejemplo de salida:

```
clientes_url       = "https://xxxxxxxx.execute-api.us-east-2.amazonaws.com/dev/clientes"
transferencias_url = "https://xxxxxxxx.execute-api.us-east-2.amazonaws.com/dev/transferencias"
```

## API — Endpoints

### POST `/clientes`

Crea un cliente en DynamoDB.

**Body (JSON):**

```json
{
  "nombre": "Luz Maria",
  "correo": "luz@test.com"
}
```

**Respuesta exitosa (200):**

```json
{
  "id": "uuid-generado",
  "nombre": "Luz Maria",
  "correo": "luz@test.com",
  "fecha_creacion": "2026-05-30T12:00:00.000000"
}
```

**Validaciones (400):**

| Caso | Mensaje |
|---|---|
| Body vacío `{}` | El nombre es obligatorio |
| Nombre o correo ausentes | Campo obligatorio |
| Nombre o correo vacíos `""` | Nombre vacío / Correo vacío |

**Ejemplo con curl:**

```bash
curl -X POST "https://TU_API/dev/clientes" \
  -H "Content-Type: application/json" \
  -d "{\"nombre\": \"Luz Maria\", \"correo\": \"luz@test.com\"}"
```

### POST `/transferencias`

Registra una transferencia en DynamoDB.

**Body (JSON):**

```json
{
  "cuenta_origen": "001",
  "cuenta_destino": "002",
  "monto": 500
}
```

**Respuesta exitosa (200):**

```json
{
  "transferencia_id": "uuid-generado",
  "cuenta_origen": "001",
  "cuenta_destino": "002",
  "monto": 500,
  "fecha_transferencia": "2026-05-30T12:00:00.000000"
}
```

**Ejemplo con curl:**

```bash
curl -X POST "https://TU_API/dev/transferencias" \
  -H "Content-Type: application/json" \
  -d "{\"cuenta_origen\": \"001\", \"cuenta_destino\": \"002\", \"monto\": 500}"
```

## Plan de pruebas

### Clientes

1. Enviar body válido → verificar **HTTP 200** y JSON con `id`, `nombre`, `correo`.
2. Enviar `{}` → verificar **HTTP 400**.
3. Enviar `{"nombre": "", "correo": ""}` → verificar **HTTP 400**.

### Transferencias

1. Enviar body válido → verificar **HTTP 200** y JSON con `transferencia_id`.
2. Confirmar el registro en la tabla `transferencias` de DynamoDB.

## Verificación en AWS

### DynamoDB

1. Consola AWS → **DynamoDB** → **Tables**.
2. Revisar tabla `clientes`: debe aparecer el cliente con `id`, `nombre` y `correo`.
3. Revisar tabla `transferencias`: debe aparecer la transferencia registrada.

### CloudWatch Logs

1. Consola AWS → **CloudWatch** → **Log groups**.
2. `/aws/lambda/crear_cliente` → abrir el log stream más reciente.
3. Validar logs personalizados: `===== NUEVO REQUEST =====`, `Cliente almacenado: ...`
4. `/aws/lambda/realizar_transferencia` → validar `===== NUEVA TRANSFERENCIA =====` y transferencias procesadas.

### Actualización de Lambdas vía Terraform

1. Modificar un `print()` en cualquier Lambda.
2. Ejecutar `terraform fmt` y `terraform apply`.
3. Terraform detecta el cambio (`source_code_hash`) y actualiza la función automáticamente.
4. Enviar varios requests y confirmar nuevas ejecuciones en CloudWatch.

## Empaquetar Lambdas manualmente (opcional)

Terraform ya empaqueta con `archive_file`. Si modificas el código y quieres generar el `.zip` a mano:

```powershell
cd lambdas/crear_cliente
Compress-Archive -Path main.py -DestinationPath lambda.zip -Force

cd ../realizar_transferencia
Compress-Archive -Path main.py -DestinationPath lambda.zip -Force
```

En Linux, macOS o Git Bash:

```bash
cd lambdas/crear_cliente && zip -r lambda.zip .
cd ../realizar_transferencia && zip -r lambda.zip .
```

## Evidencias de entrega

| # | Evidencia |
|---|---|
| 1 | Captura de `terraform apply` mostrando tablas DynamoDB, Lambdas, API Gateway, IAM Roles y permisos |
| 2 | Captura del endpoint funcionando (Postman/curl) con **HTTP 200** y JSON retornado |
| 3 | Captura de registros en DynamoDB (`clientes`: id, nombre, correo) |
| 4 | Captura de logs exitosos en CloudWatch (ejecución Lambda, logs personalizados) |
| 5 | Captura de la estructura del proyecto (carpetas, `.tf`, Lambdas) |

## Restricciones importantes

**No está permitido:**

- Crear recursos manualmente desde AWS Console
- Modificar API Gateway, DynamoDB, IAM, Lambda o CloudWatch desde la consola
- Crear tablas, Lambdas o APIs fuera de Terraform

Toda la infraestructura debe mantenerse administrada **únicamente con Terraform**.

## Notas

- No subas archivos con credenciales (`terraform.tfvars`, `.env`, claves AWS, etc.).
- El estado de Terraform (`*.tfstate`) está en `.gitignore`; cada equipo gestiona su estado local o remoto según indique el profesor.
- Las Lambdas usan **Python 3.9** como runtime en AWS.
- `boto3` ya está incluido en el runtime de Lambda; `requirements.txt` documenta la dependencia para desarrollo local.

## Checklist de validación final

- [ ] Clientes creados correctamente en DynamoDB
- [ ] Transferencias almacenadas en DynamoDB
- [ ] Logs visibles en CloudWatch para ambas Lambdas
- [ ] API Gateway responde en `/clientes` y `/transferencias`
- [ ] Infraestructura creada y actualizada solo con Terraform
- [ ] Evidencias capturadas (Terraform, Postman, DynamoDB, CloudWatch, estructura)
