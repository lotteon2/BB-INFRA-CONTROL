module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${local.cluster_name}-vpc"
  cidr = local.vpc_cidr

  azs                 = local.azs
  public_subnets      = ["10.194.0.0/24", "10.194.1.0/24"]
  public_subnet_names = ["${local.cluster_name}-pub-a-sn", "${local.cluster_name}-pub-c-sn"]
  public_subnet_tags  = {
    "kubernetes.io/role/elb" = 1  # 해당 태그 지정 시, k8s 내에서 ingress 생성 시 서브넷 자동 지정
  }

  enable_nat_gateway      = false
  enable_dns_support      = true
  map_public_ip_on_launch = true

  enable_dns_hostnames = true

  tags = local.tags
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}