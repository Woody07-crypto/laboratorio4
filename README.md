# Laboratorio 4 — Terraform y AWS Lambda

Plantilla del laboratorio de **Desarrollo en la Nube**: infraestructura serverless con Terraform y funciones Lambda en Python.

## Estructura del proyecto

```
laboratorio4/
├── terraform/          # Infraestructura en AWS
├── lambdas/
│   ├── crear_cliente/
│   └── realizar_transferencia/
└── README.md
```

## Requisitos

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.0
- [AWS CLI](https://aws.amazon.com/cli/) configurado (`aws configure`)
- Python 3.x (para empaquetar las Lambdas si modificas el código)

## Clonar el repositorio

```bash
git clone https://github.com/Woody07-crypto/laboratorio4.git
cd laboratorio4
```

## Configuración de AWS

Configura tus credenciales con la región del laboratorio:

```bash
aws configure
# Default region: us-east-2
```

Si usas el perfil de un compañero (cuenta compartida del curso):

```powershell
aws configure --profile companero
$env:AWS_PROFILE = "companero"
```

## Uso con Terraform

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

## Empaquetar Lambdas (opcional)

Si cambias el código Python, vuelve a generar el `.zip` antes de desplegar:

```powershell
cd lambdas/crear_cliente
Compress-Archive -Path main.py -DestinationPath lambda.zip -Force

cd ../realizar_transferencia
Compress-Archive -Path main.py -DestinationPath lambda.zip -Force
```

## Notas

- No subas archivos con credenciales (`terraform.tfvars`, `.env`, etc.).
- El estado de Terraform (`*.tfstate`) está ignorado en Git; cada compañero gestiona su propio estado local o remoto según indique el profesor.
