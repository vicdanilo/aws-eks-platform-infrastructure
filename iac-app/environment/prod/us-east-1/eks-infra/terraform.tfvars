########################################
# Environment setting
########################################
region     = "us-east-1"
account_id = ""
role_name  = ""
user_name  = ""
env        = "prod"
app_name   = "eks-infra"

########################################
# VPC
########################################
cidr                               = "10.1.0.0/16"
azs                                = ["us-east-1a", "us-east-1c", "us-east-1d"]
public_subnets                     = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"] # 256 IPs per subnet
private_subnets                    = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]
database_subnets                   = ["10.1.105.0/24", "10.1.106.0/24", "10.1.107.0/24"]
enable_dns_hostnames               = "true"
enable_dns_support                 = "true"
enable_nat_gateway                 = "true" # need internet connection for worker nodes in private subnets to be able to join the cluster 
single_nat_gateway                 = "true"
manage_default_network_acl         = "false"
manage_default_route_table         = "false"
manage_default_security_group      = "false"
create_database_subnet_group       = "true"
create_database_subnet_route_table = "true"


## Public Security Group ##
public_ingress_with_cidr_blocks = []

create_eks = true

########################################
# EKS
########################################
cluster_version                = 1.32
cluster_endpoint_public_access = true # need this otherwise can't access EKS from outside VPC. Unless set up bastion

# note (only for unmanaged node group)
# need to use kubelet_extra_args to propagate taints/labels to K8s node, because ASG tags not being propagated to k8s node objects.
self_managed_node_groups = {
  prod = {
    name          = "worker-group-prod-1"
    instance_type = "t2.small" #"t3a.medium"
    # ami_type      = "ami-0e4b6125d7893a777" # It will pick up the latest one if not specified
    max_size     = 3
    min_size     = 3
    desired_size = 3

    tags = {
      "unmanaged-node"                    = "true"
      "k8s.io/cluster-autoscaler/enabled" = "true" # need this tag so clusterautoscaler auto-discovers node group: https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/autoscaling.md
      "k8s_namespace"                     = "prod"
      "env"                               = "prod"
    }
  },
}

########################################
# RDS
########################################
engine                              = "postgres"
engine_version                      = "14"
db_name                             = "app_development"
instance_class                      = "db.t3.small"
allocated_storage                   = 50
family                              = "postgres14"
storage_type                        = "gp3"
storage_encrypted                   = true
enabled_cloudwatch_logs_exports     = ["postgresql", "upgrade"]
create_cloudwatch_logs_group        = true
create_monitor_role                 = true
username                            = "app"
iam_database_authentication_enabled = false
deletion_protection                 = true

########################################
# ECR
########################################
## ECR ##
ecr_name                 = "app"
ecr_image_tag_mutability = "MUTABLE"
github_repository        = "vicdanilo/noname"