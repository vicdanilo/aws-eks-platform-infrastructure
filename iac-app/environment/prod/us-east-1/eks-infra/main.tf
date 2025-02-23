########################################
# VPC
########################################
module "vpc" {
  source = "../../../../infra_modules/vpc"

  name                 = var.app_name
  cidr                 = var.cidr
  azs                  = var.azs
  private_subnets      = var.private_subnets
  public_subnets       = var.public_subnets
  database_subnets     = var.database_subnets
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = var.single_nat_gateway

  create_database_subnet_group       = var.create_database_subnet_group
  create_database_subnet_route_table = var.create_database_subnet_route_table

  ## Public Security Group ##
  public_ingress_with_cidr_blocks = var.public_ingress_with_cidr_blocks

  ## Private Security Group ##
  # bastion EC2 not created yet
  # bastion_sg_id  = module.bastion.security_group_id

  ## Database security group ##
  # pass EKS worker SG to DB SG after creating EKS module at composition layer
  databse_computed_ingress_with_eks_worker_source_security_group_ids = local.databse_computed_ingress_with_eks_worker_source_security_group_ids

  cluster_name = local.cluster_name

  ## Common tag metadata ##
  env      = var.env
  app_name = var.app_name
  tags     = local.vpc_tags
  region   = var.region
}

########################################
# EKS
########################################
module "eks" {
  source = "../../../../infra_modules/eks"

  ## EKS ##
  create_eks                     = var.create_eks
  cluster_version                = var.cluster_version
  cluster_name                   = local.cluster_name
  cluster_endpoint_public_access = var.cluster_endpoint_public_access
  vpc_id                         = module.vpc.vpc_id
  subnets                        = module.vpc.private_subnets

  self_managed_node_groups = var.self_managed_node_groups

  create_kms_key            = var.create_kms_key
  cluster_encryption_config = var.cluster_encryption_config

  access_entries = local.access_entries

  ## bastion ##
  bastion_sg = module.vpc.private_security_group_id

  ## Common tag metadata ##
  env      = var.env
  app_name = var.app_name
  tags     = local.eks_tags
  region   = var.region

}

########################################
# RDS
########################################

module "db_instance" {
  source = "../../../../infra_modules/rds"

  create_rds = var.create_rds

  ## RDS ##
  identifier = local.db_name

  # RDS configuration
  engine            = var.engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  family            = var.family
  parameters        = var.parameters
  storage_type      = var.storage_type
  storage_encrypted = var.storage_encrypted

  # Cloudwatch parameters
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  create_cloudwatch_log_group     = var.create_cloudwatch_log_group
  create_monitoring_role          = var.create_monitoring_role

  # DB configuration
  db_name  = try(var.db_name, local.db_name)
  username = var.username
  port     = var.port

  # IAM, security and networking
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  deletion_protection                 = var.deletion_protection
  vpc_security_group_ids              = [module.vpc.database_security_group_id]
  db_subnet_group_name                = module.vpc.database_subnet_group

  options = var.options
  tags    = local.rds_tags
}

########################################
# ECR
########################################
module "ecr" {
  source = "../../../../infra_modules/ecr"

  create_ecr = var.create_ecr

  ## ECR repo ##
  ecr_name                 = var.ecr_name
  ecr_image_tag_mutability = var.ecr_image_tag_mutability
  worker_role_arn          = try(module.eks.self_managed_node_groups.prod.iam_role_arn, "")

  ## For OIDC ##
  github_repository = var.github_repository

  tags = local.tags
}

########################################
# Helm Charts
########################################
# module "helm_charts" {
#   source = "../../../../infra_modules/helm_charts"

#   cluster_name = local.cluster_name
#   alb_svc_role = module.eks.alb_controller_iam_role_name

# }