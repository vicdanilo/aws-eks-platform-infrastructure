# This configuration is for an Application Load Balancer (ALB)
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/lbc-helm.html

########################################
# ALB Role
########################################
module "aws_alb_role" {

  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 5.0"

  create_role = true

  role_name = "eks-loadbalancer-controller"

  provider_url                   = var.provider_url
  oidc_fully_qualified_audiences = ["sts.amazonaws.com"]
  oidc_fully_qualified_subjects  = ["system:serviceaccount:kube-system:${local.alb_controller_name}"]

  role_policy_arns = [
    try(module.aws_load_balancer_controller_policy.arn, ""),
  ]
  number_of_role_policy_arns = 1

  tags = merge(
    { Role = "eks-loadbalancer-controller" },
    var.tags
  )
}

module "aws_load_balancer_controller_policy" {

  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 5.0"

  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "Policy for AWS Load Balancer Controller"

  policy = file("${path.module}/alb_iam_policy.json")

  tags = var.tags
}

########################################
# AWS ALB Helm Chart
########################################
resource "helm_release" "aws_load_balancer_controller" {

  name = local.alb_controller_name

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.11.0"

  values = [
    templatefile(
      "${path.module}/values/alb/aws-loadbalancer-controller.yaml",
      {
        cluster_name = var.cluster_name,
        alb_svc_name = local.alb_controller_name,
        alb_svc_role = module.aws_alb_role.iam_role_arn
      }
    )
  ]

  depends_on = [module.aws_alb_role]

}
