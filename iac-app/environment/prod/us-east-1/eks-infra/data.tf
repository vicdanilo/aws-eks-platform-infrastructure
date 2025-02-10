locals {
  tags = {
    Region      = var.region
    Environment = var.env
    Application = var.app_name
    Terraform   = true
  }

  ########################################
  # VPC
  ########################################
  vpc_name = "vpc-${var.region_tag[var.region]}-${var.env}-${var.app_name}"
  vpc_tags = merge(
    local.tags,
    tomap({
      "VPC-Name" = local.vpc_name
    })
  )

  # add three ingress rules from EKS worker SG to DB SG only when creating EKS cluster
  databse_computed_ingress_with_eks_worker_source_security_group_ids = var.create_eks ? [
    {
      rule                     = "postgresql-tcp"
      source_security_group_id = module.eks.node_security_group_id
      description              = "postgresql from EKS SG in private subnet"
    },
    {
      rule                     = "redis-tcp"
      source_security_group_id = module.eks.node_security_group_id
      description              = "redis from EKS SG in private subnet"
    },
  ] : []

  ########################################
  # EKS
  ########################################
  ## EKS ##
  cluster_name = "eks-${var.region_tag[var.region]}-${var.env}-${var.app_name}"

  eks_tags = {
    Environment = var.env
    Application = var.app_name
    Terraform   = true
  }

  account_id                = var.account_id != "" ? var.account_id : data.aws_caller_identity.this.account_id
  primary_iam_principal_arn = var.role_name != "" ? "arn:aws:iam::${local.account_id}:role/${var.role_name}" : var.user_name != "" ? "arn:aws:iam::${local.account_id}:user/${var.user_name}" : data.aws_caller_identity.this.arn
  access_entries = [
    {
      name                    = "EKS SuperAdmin"
      iam_principal_arn       = local.primary_iam_principal_arn
      access_permission_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
      access_scope            = "cluster"
      access_scope_namespaces = []
      kubernetes_groups       = []
    }
  ]

  ########################################
  # RDS
  ########################################
  rds_tags = {
    Environment = var.env
    Application = var.app_name
    Terraform   = true
  }
  db_name = "db-${var.region_tag[var.region]}-${var.env}-${var.app_name}"
}

data "aws_caller_identity" "this" {}