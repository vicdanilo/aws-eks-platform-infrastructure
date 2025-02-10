module "ecr" {
  source = "../../resource_modules/container/ecr"

  ## ECR repo ##
  name                 = var.ecr_name
  image_tag_mutability = var.ecr_image_tag_mutability
  tags                 = var.tags

  ecr_repo_policy = data.aws_iam_policy_document.app_ecr_policy.json
  ecr_lifecycle_policy = local.ecr_lifecycle_policy
}

module "github-oidc" {
  source  = "terraform-module/github-oidc-provider/aws"
  version = "~> 2.0"

  create_oidc_provider = true
  create_oidc_role     = true

  repositories              = [var.github_repository]
  oidc_role_attach_policies = [module.github-actions-policy.arn]

  tags = var.tags
}

module "github-actions-policy"  {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 5.0"

  name = "github-to-ecr-policy"
  path = "/github-actions/"

  policy = data.aws_iam_policy_document.github_oidc_policy.json

  tags = var.tags
}
