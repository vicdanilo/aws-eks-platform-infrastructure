# This configuration is for an Application Load Balancer (ALB)
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/lbc-helm.html

module "aws_alb_role" {
  count = var.create_eks && var.create_alb_role ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"

  create_role = true

  role_name = "eks-loadbalancer-controller"

  provider_url = try(module.eks_cluster[0].cluster_oidc_issuer_url, "")
  oidc_fully_qualified_audiences = ["sts.amazonaws.com"]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]

  role_policy_arns = [
    try(module.aws_load_balancer_controller_policy[0].arn, ""),
  ]
  number_of_role_policy_arns = 1

  tags = merge(
    {Role = "eks-loadbalancer-controller"},
    var.tags
  )
}

module "aws_load_balancer_controller_policy" {
  count = var.create_eks && var.create_alb_role ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 5.0"

  name = "AWSLoadBalancerControllerIAMPolicy"
  description = "Policy for AWS Load Balancer Controller"

  policy = file("${path.module}/alb_iam_policy.json")

  tags = var.tags
}