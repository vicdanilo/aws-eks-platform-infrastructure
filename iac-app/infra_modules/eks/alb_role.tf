# This configuration is for an Application Load Balancer (ALB)
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/lbc-helm.html

resource "aws_iam_policy" "AWSLoadBalancerControllerIAMPolicy" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "Policy for AWS Load Balancer Controller"
  policy      = file("${path.module}/alb_iam_policy.json")
}

data "aws_iam_policy_document" "trust_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${local.account_id}:oidc-provider/oidc.eks.${local.aws_region}.amazonaws.com/id/${local.oidcId}"]
    }

    condition {
      test     = "StringEquals"
      variable = "oidc.eks.us-east-1.amazonaws.com/id/${local.oidcId}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "oidc.eks.us-east-1.amazonaws.com/id/${local.oidcId}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "aws_iam_role" "AWSLoadBalancerControllerIAMRole" {
  name               = "eks-loadbalancer-controller"
  assume_role_policy = data.aws_iam_policy_document.trust_policy.json
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.AWSLoadBalancerControllerIAMRole.name
  policy_arn = aws_iam_policy.AWSLoadBalancerControllerIAMPolicy.arn
}