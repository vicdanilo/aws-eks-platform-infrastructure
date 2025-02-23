locals {
  ## VPC ##  
  public_subnet_tags = {
    # need to tag subnets with "shared" so K8s can find right subnets to create ELBs
    "Tier" = "public"
    "kubernetes.io/role/elb" = 1
  }

  # need tag for internal-elb to be able to create ELB
  private_subnet_tags = {

    "Tier" = "private"
    "karpenter.sh/discovery" = "${var.cluster_name}"
    "kubernetes.io/role/internal-elb" = 1
  }

  database_subnet_tags = {
    "Tier" = "database"
  }

  ## Public SG ##
  public_security_group_name        = "scg-${var.region_tag[var.region]}-${var.env}-public"
  public_security_group_description = "Security group for public subnets"
  public_security_group_tags = merge(
    var.tags,
    tomap({
      "Name" = local.public_security_group_name
    }),
    tomap({
      "Tier" = "public"
    }),
    tomap({
      "karpenter.sh/discovery" = "${var.cluster_name}"
    }),
  )

  ## Private SG ##
  private_security_group_name        = "scg-${var.region_tag[var.region]}-${var.env}-private"
  private_security_group_description = "Security group for private subnets"
  private_security_group_tags = merge(
    var.tags,
    tomap({
      "Name" = local.private_security_group_name
    }),
    tomap({
      "Tier" = "private"
    }),
  )

  ## DB SG ##
  db_security_group_name        = "scg-${var.region_tag[var.region]}-${var.env}-database"
  db_security_group_description = "Security group for database subnets"
  db_security_group_tags = merge(
    var.tags,
    tomap({
      "Name" = local.db_security_group_name
    }),
    tomap({
      "Tier" = "database"
    }),
  )

  db_security_group_computed_ingress_with_source_security_group_id = [
    {
      rule                     = "postgresql-tcp"
      source_security_group_id = module.private_security_group.security_group_id
      description              = "postgres from private SG"
    },
    {
      rule                     = "redis-tcp"
      source_security_group_id = module.private_security_group.security_group_id
      description              = "redis from private SG"
    },
  ]
}

# EKS worker SG not created yet
# data "aws_security_group" "eks_worker_sg" {
#   tags = {
#     Name = "eks-ue1-prod-XXX-api-infra-eks_worker_sg"
#   }

#   id = "scg-08fc14b9cb38d325c"
# }