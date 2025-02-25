provider "aws" {
  region                   = "us-east-1" # Reemplaza con tu región
  profile                  = "tfm"
  shared_credentials_files = "~/.aws/credentials"
  shared_config_files      = "~/.aws/config"
}