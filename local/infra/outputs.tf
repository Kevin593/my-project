output "eks_cluster_name" {
  description = "Nombre del cluster de EKS"
  value       = module.eks.eks_cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint del cluster de EKS"
  value       = module.eks.eks_cluster_endpoint
}

output "vpc_id" {
  description = "ID de la VPC"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "IDs de las subnets públicas"
  value       = module.vpc.public_subnets
}