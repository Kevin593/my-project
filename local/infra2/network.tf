module "vpc" {
    source = "terraform-aws-modules/vpc/aws"

    name ="redcluster"


    cidr            = "10.0.0.0/16"  # Rango de IPs para la VPC
    azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]  # Zonas de disponibilidad
    private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]  # Subredes privadas
    public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]  # Subredes públicas

    create_igw = true
    enable_nat_gateway = true
    single_nat_gateway= true

    tags ={
        Terraform = true
        Environment = "cluster"

    }
}