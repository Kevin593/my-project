provider "aws" {
  region                   = "us-east-1"                      # Especifica la región de AWS
  shared_credentials_files = ["~/.aws/credentials"]           # Lista con la ruta al archivo de credenciales
  shared_config_files      = ["~/.aws/config"]                # Lista con la ruta al archivo de configuración
  profile                  = "practica1"                       # Nombre del perfil a utilizar
}

