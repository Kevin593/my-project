# modules/eks/main.tf

# Crea un clúster EKS
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }
}

# Crea un rol de IAM para el clúster EKS
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.cluster_name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

# Adjunta la política de IAM al rol
resource "aws_iam_policy_attachment" "eks_cluster_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  roles      = [aws_iam_role.eks_cluster_role.name]
  name       = "${aws_iam_role.eks_cluster_role.name}-policy-attachment"
}

# Crea un rol de IAM para el grupo de nodos
resource "aws_iam_role" "eks_node_group_role" {
  name = "${var.cluster_name}-eks-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

# Adjunta las políticas de IAM al rol 
resource "aws_iam_policy_attachment" "eks_node_group_policy_attachment_worker" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  roles      = [aws_iam_role.eks_node_group_role.name]
  name       = "${aws_iam_role.eks_node_group_role.name}-worker-policy-attachment"
}

resource "aws_iam_policy_attachment" "eks_node_group_policy_attachment_cni" {
  policy_arn = "arn:aws:iam::211125320705:policy/EKS-CNI-Policy"
  roles      = [aws_iam_role.eks_node_group_role.name]
  name       = "${aws_iam_role.eks_node_group_role.name}-cni-policy-attachment"
}


resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "my-node-group"
  version         = aws_eks_cluster.main.version
  subnet_ids      = var.subnet_ids
  instance_types  = var.instance_types

  scaling_config {
    desired_size = 3
    max_size     = 5
    min_size     = 2
  }

  
  node_role_arn = aws_iam_role.eks_node_group_role.arn
  depends_on = [aws_eks_cluster.main] 
  
}
variable "cluster_name" {
  type = string
  description = "Name of the EKS cluster"
}

variable "cluster_version" {
  type = string
  description = "Kubernetes version for the EKS cluster"
}

variable "instance_types" {
  type = list(string)
  description = "List of instance types for the node group"
}

variable "desired_capacity" {
  type = number
  description = "Desired number of nodes in the node group"
}

variable "min_size" {
  type = number
  description = "Minimum number of nodes in the node group"
}

variable "max_size" {
  type = number
  description = "Maximum number of nodes in the node group"
}

variable "vpc_id" {
  type = string
  description = "ID of the VPC"
}

variable "subnet_ids" {
  type = list(string)
  description = "List of subnet IDs for the EKS cluster and node group"
}