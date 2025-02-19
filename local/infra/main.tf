module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  cidr = var.vpc_cidr
  azs  = var.availability_zones

  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"] 
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway = true 
  single_nat_gateway = true

  tags = {
    Name = "my-vpc"
  }
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0" 

  cluster_name                    = var.cluster_name
  cluster_version                 = var.cluster_version
  cluster_endpoint_private_access = false # No es necesario en subnets públicas
  cluster_endpoint_public_access  = true  # Habilita acceso público

  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  cluster_service_ipv4_cidr = "10.100.0.0/16" 
}

module "eks_node_group" {
  source  = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
  version = "~> 20.0"

  cluster_name = module.eks.cluster_name
  subnet_ids   = module.vpc.private_subnets
  cluster_service_cidr  = "10.100.0.0/16"

  name            = "worker-group-1"
  instance_types  = var.instance_types
  desired_size    = var.desired_capacity
  min_size        = var.min_size
  max_size        = var.max_size
}

