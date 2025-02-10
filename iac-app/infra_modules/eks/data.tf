locals {
  ## Key Pair ##
  key_pair_name = "eks-workers-keypair-${var.region_tag[var.region]}-${var.env}-${var.app_name}"

  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEIWqqhEWd8e0VQKsZel3nbvHXBxclFcwW6AVqKzPq6h test@test.com"

    lifecycle_policy = <<EOT
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Expire images older than 30 days",
      "selection": {
        "tagStatus": "tagged",
        "tagPrefixList": [ "prod" ],
        "countType": "imageCountMoreThan",
        "countNumber": 30
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOT

  ## ALB ##
  account_id               = data.aws_caller_identity.current.account_id
  aws_region               = data.aws_region.current.name

  oidcId = element(split("/", module.eks_cluster.oidc_provider_arn), length(split("/", module.eks_cluster.oidc_provider_arn)) - 1)

  ##  bastion ##
  bastion_name = "${var.cluster_name}-bastion"
  bastion_sg   = "${var.cluster_name}-bastion-sg"
  bastion_tags = merge(
    { Name = local.bastion_name },
    var.tags,
  )
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# current account ID
data "aws_caller_identity" "this" {}

## ECR ##
data "aws_iam_policy_document" "worker_ecr_pull_policy" {
  statement {
    sid    = "GitHubActionsPush"
    effect = "Allow"

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability"
    ]

    resources = ["*"]
  }
}

## bastion ##
data "aws_ami" "amazon_linux_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}