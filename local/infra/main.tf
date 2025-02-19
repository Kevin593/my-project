
# Llamada al módulo de VPC
module "vpc" {
  source = "vpc"
  app_name = var.app_name
}

# Llamada al módulo de IAM
module "iam" {
  source = "iam"
  app_name = var.app_name
}

# Llamada al módulo de EKS
module "eks" {
  source = "eks"
  app_name = var.app_name
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets
  eks_cluster_role_arn = module.iam.eks_cluster_role_arn
}