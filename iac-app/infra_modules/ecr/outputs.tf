################################################################################
# ECR
################################################################################
output "ecr_arn" {
  description = "Full ARN of the repository."
  value       = module.ecr.arn
}
output "ecr_name" {
  description = "The name of the repository."
  value       = module.ecr.name
}
output "ecr_registry_id" {
  description = "The registry ID where the repository was created."
  value       = module.ecr.registry_id
}
output "ecr_repository_url" {
  description = "The URL of the repository (in the form aws_account_id.dkr.ecr.region.amazonaws.com/repositoryName)."
  value       = module.ecr.repository_url
}

## ECR repo policy ##
output "ecr_repo_policy" {
  description = "policy - (Required) The policy document. This is a JSON formatted string."
  value       = module.ecr.repo_policy
}

## ECR lifecycle policy ##
output "ecr_lifecycle_policy" {
  description = "policy - (Required) The policy document. This is a JSON formatted string."
  value       = module.ecr.lifecycle_policy
}

## OIDC ##
output "oidc_provider_arn" {
  description = "OIDC provider ARN"
  value       = module.github-oidc.oidc_provider_arn
}

output "oidc_role" {
  description = "CICD GitHub role."
  value       = module.github-oidc.oidc_role
}