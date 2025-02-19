variable "region" {
  type = string
  description = "AWS region"
  default = "us-east-1"
}

variable "vpc_cidr_block" {
  type = string
  description = "CIDR block for the VPC"
  default = "10.0.0.0/16"
}

variable "availability_zones" {
  type = list(string)
  description = "List of availability zones to use"
  default = ["us-east-1a", "us-east-1b"]
}

variable "cluster_name" {
  type = string
  description = "Name of the EKS cluster"
  default = "my-cluster"
}

variable "cluster_version" {
  type = string
  description = "Kubernetes version for the EKS cluster"
  default = "1.27"
}

variable "instance_types" {
  type = list(string)
  description = "List of instance types for the node group"
  default = ["t3.medium"]
}

variable "desired_capacity" {
  type = number
  description = "Desired number of nodes in the node group"
  default = 3
}

variable "min_size" {
  type = number
  description = "Minimum number of nodes in the node group"
  default = 2
}

variable "max_size" {
  type = number
  description = "Maximum number of nodes in the node group"
  default = 5
}

variable "subnet_ids" {
  type = list(string)
  description = "List of subnet IDs for the EKS cluster and node group"
}

variable "vpc_id" {
  type = string
  description = "ID of the VPC"
}
