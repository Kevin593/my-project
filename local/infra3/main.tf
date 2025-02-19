# Configura el proveedor de AWS
provider "aws" {
  region = var.region
  profile = "practica1"  
}

# Crea la VPC
module "vpc" {
  source = "./modules/vpc"
  cidr_block = var.vpc_cidr_block
  availability_zones = var.availability_zones
}

# Crea el clúster EKS
module "eks" {
  source = "./modules/eks"
  cluster_name = var.cluster_name
  cluster_version = var.cluster_version
  instance_types = var.instance_types
  desired_capacity = var.desired_capacity
  min_size = var.min_size
  max_size = var.max_size
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.subnet_ids
}