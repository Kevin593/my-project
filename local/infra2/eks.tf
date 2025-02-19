module "eks" {
    source = "terraform-aws-modules/eks/aws"

    version          = "~> 19.0"

    cluster_name = "boleteria-eks"
    cluster_version = "1.26"
     vpc_id = module.vpc.vpc_id
     subnet_ids=module.vpc.private_subnets
     cluster_endpoint_public_access = true
      cluster_endpoint_private_access = true


      cluster_addons ={

        core_dns = {
            resolve_conflict= "OVERWRITE"
        }

          vpc_cni = {
            resolve_conflict= "OVERWRITE"
        }

          kube_proxy = {
            resolve_conflict= "OVERWRITE"
        }


      }

manage_aws_auth_configmap =  true

eks_managed_node_groups = {
    node-group = {
        desired_caacity = 1
        max_caacity =2
        min_caacity= 1
        instance_type = "[t3.medium]"

        tags = {
            Environment = "cluster"
        }
    }
}

   tags ={
        Terraform = true
        Environment = "cluster"

    }
}

