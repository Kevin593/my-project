variable "aws_region" {
  description = "Región de AWS"
  default     = "us-east-1"
}

variable "app_name" {
  description = "Nombre de la aplicación"
  default     = "boleteria-eventos"
}

variable "eks_cluster_role_arn" {
  description = "ARN del rol de IAM para el cluster de EKS"
  type        = string
}

variable "subnet_ids" {
  description = "IDs de las subnets para el cluster de EKS"
  type        = list(string)
}