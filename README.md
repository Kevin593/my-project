# Mi Proyecto en la Nube

Este proyecto despliega una aplicación full-stack en AWS usando Terraform, Docker y GitHub Actions.

## Componentes
- **Frontend**: Aplicación React.
- **Backend**: API en Python (Flask/FastAPI) o Go.
- **Base de Datos**: MongoDB.

## Requisitos
- Docker
- Docker Compose
- Terraform
- AWS CLI

## Desarrollo Local
1. Clona el repositorio.
2. Ejecuta `docker-compose up` en la carpeta `app/`.
3. Accede al frontend en `http://localhost:3000`.

## Despliegue en AWS
1. Configura las credenciales de AWS.
2. Ejecuta `terraform apply` en la carpeta `infra/`.
3. Los cambios en `main` se despliegan automáticamente mediante GitHub Actions.