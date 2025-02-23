## ECR ##
locals {
  ecr_lifecycle_policy = <<EOT
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

}

data "aws_iam_policy_document" "github_oidc_policy" {
  version = "2012-10-17"

  statement {
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:InitiateLayerUpload",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage"
    ]
    resources = [try(module.ecr[0].arn, "")]
  }

  statement {
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "app_ecr_policy" {
  statement {
    sid    = "AllowGitHubActionsPush"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [try(module.github-oidc[0].oidc_role, "")]
    }

    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:ListImages",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]
  }

  statement {
    sid    = "AllowWorkerNodePull"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [var.worker_role_arn]
    }

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:GetAuthorizationToken"
    ]
  }

  # Deny all other principals except the GitHub Actions role and the worker iam role
  statement {
    sid    = "DenyAllOtherPrincipals"
    effect = "Deny"

    principals {
      type        = "AWS"
      identifiers = ["*"]  
    }

    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:ListImages",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]

    condition {
      test     = "ArnNotLike"
      variable = "aws:PrincipalArn"
      values   = [try(module.github-oidc[0].oidc_role, ""), var.worker_role_arn] 
    }
  }
}