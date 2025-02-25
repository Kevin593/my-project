# Voting Platform Backend

Este es el backend para la plataforma de votaciones en tiempo real implementado en Go. Proporciona una API RESTful que se conecta a MongoDB y ofrece endpoints para administrar opciones de votación y registrar votos.

## Características

- API RESTful implementada con Gin
- Documentación Swagger integrada
- Conexión a MongoDB
- Monitoreo con Elastic APM (opcional)
- CORS habilitado para comunicación con el frontend

## Endpoints

1. Health Check: `GET /api/v1/health`
2. Initialize Test Data: `POST /api/v1/init-data`
3. Get All Options: `GET /api/v1/options`
4. Vote for an Option: `POST /api/v1/vote`

## Configuración

### Requisitos previos

- Go 1.20 o superior
- MongoDB
- Docker y Docker Compose (opcional)

### Variables de entorno

Configura las siguientes variables de entorno en un archivo `.env`:

```
MONGODB_URI=mongodb://localhost:27017
PORT=8080
```

Para habilitar el monitoreo con Elastic APM (opcional):

```
APM_SERVER_URL=http://apm-server:8200
APM_SERVICE_NAME=voting-platform-backend
APM_ENVIRONMENT=