# Buscar la VPC existente por nombre
data "aws_vpc" "existing" {
  filter {
    name   = "tag:Name"
    values = ["tfm-vpc"]  # Cambia esto por el nombre de la VPC que buscas
  }
}

# Crear la VPC solo si no existe
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"
  name    = "tfm-vpc"

  count  = length(data.aws_vpc.existing.ids) == 0 ? 1 : 0  # Solo crea si no existe

  cidr = var.vpc_cidr
  azs  = var.availability_zones

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  enable_dns_hostnames = true
  enable_nat_gateway   = true
  single_nat_gateway   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name                             = var.cluster_name
  cluster_version                          = var.cluster_version
  cluster_endpoint_private_access          = false # Desactivado si quieres acceso público
  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    aws-ebs-csi-driver = {
      service_account_role_arn = module.irsa-ebs-csi.iam_role_arn
    }
  }

  # Usar la VPC existente si ya existe, o la nueva si se crea
  vpc_id     = length(data.aws_vpc.existing.ids) > 0 ? data.aws_vpc.existing.ids[0] : module.vpc[0].vpc_id
  subnet_ids = module.vpc.private_subnets # Asegurando uso de subredes privadas (puedes ajustar esto)

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  eks_managed_node_groups = {
    one = {
      name = "worker-group-tfm"
      instance_types = ["t3.small"]
      min_size     = var.min_size
      max_size     = var.max_size
      desired_size = var.desired_capacity
    }
  }
}

data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

module "irsa-ebs-csi" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.39.0"

  create_role                   = true
  role_name                     = "AmazonEKSTFEBSCSIRole-${module.eks.cluster_name}"
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [data.aws_iam_policy.ebs_csi_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
}

# Configuración correcta del proveedor Kubernetes
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}
