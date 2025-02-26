module "key_pair" {
  source = "../../resource_modules/compute/ec2_key_pair"

  key_name   = local.key_pair_name
  public_key = local.public_key
}

module "eks_cluster" {
  count = var.create_eks ? 1 : 0

  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.33"

  create = var.create_eks

  cluster_name                   = var.cluster_name
  cluster_version                = var.cluster_version
  cluster_endpoint_public_access = var.cluster_endpoint_public_access

  cluster_enabled_log_types              = var.enabled_cluster_log_types
  cloudwatch_log_group_retention_in_days = var.cluster_log_retention_in_days

  create_kms_key            = var.create_kms_key
  cluster_encryption_config = var.cluster_encryption_config

  vpc_id     = var.vpc_id
  subnet_ids = var.subnets

  cluster_addons = {
    # coredns = {}
    kube-proxy             = {}
    vpc-cni                = {}
    eks-pod-identity-agent = {}
  }

  # Self Managed Node Group(s)
  # self_managed_node_groups takes precedence to self_managed_node_group_defaults
  self_managed_node_groups = var.self_managed_node_groups

  # use KMS key to encrypt EKS worker node's root EBS volumes
  self_managed_node_group_defaults = {
    key_name = module.key_pair.key_name

    iam_role_additional_policies = { ECRPullAcessPolicy = try(module.ecr_pull_policy[0].arn, "") }
  }

  access_entries = {
    for entry in var.access_entries : entry.name => {
      kubernetes_groups = entry.kubernetes_groups
      principal_arn     = entry.iam_principal_arn

      policy_associations = {
        "${entry.name}-policy" = {
          policy_arn = entry.access_permission_arn
          access_scope = {
            type       = entry.access_scope
            namespaces = entry.access_scope_namespaces
          }
        }
      }
    }
  }

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    },
    egress_all = {
      description = "Node to all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "egress"
      cidr_blocks = ["0.0.0.0/0"]
    },
    ingress_cluster_api_ephemeral_ports_tcp = {
      description                   = "Cluster API to K8S services running on nodes"
      protocol                      = "tcp"
      from_port                     = 1025
      to_port                       = 65535
      type                          = "ingress"
      source_cluster_security_group = true
    },
  }

  cluster_security_group_additional_rules = {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "Cluster API to K8S services running on nodes"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }

  tags = var.tags
}

# Create Karpenter
# module "karpenter" {
#   source                          = "terraform-aws-modules/eks/aws//modules/karpenter"
#   version                         = "~> 20.33"
#   cluster_name                    = var.cluster_name
#   create_iam_role                 = true
#   create_instance_profile         = true
#   enable_irsa                     = true
#   irsa_namespace_service_accounts = ["kube-system:karpenter"]
#   irsa_oidc_provider_arn          = module.eks_cluster.oidc_provider_arn
#   node_iam_role_additional_policies = {}
#   tags = var.tags
# }


module "ecr_pull_policy" {
  count = var.create_eks && var.create_ecr_pull_policy ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 5.0"

  name = "worker-node-ecr-pull-policy"
  path = "/"

  policy = data.aws_iam_policy_document.worker_ecr_pull_policy.json

  tags = var.tags
}