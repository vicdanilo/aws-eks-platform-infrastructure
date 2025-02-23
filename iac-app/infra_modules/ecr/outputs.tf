################################################################################
# ECR
################################################################################
output "ecr_arn" {
  description = "Full ARN of the repository."
  value       = try(module.ecr[0].arn, null)
}
output "ecr_name" {
  description = "The name of the repository."
  value       = try(module.ecr[0].name, null)
}
output "ecr_registry_id" {
  description = "The registry ID where the repository was created."
  value       = try(module.ecr[0].registry_id, null)
}
output "ecr_repository_url" {
  description = "The URL of the repository (in the form aws_account_id.dkr.ecr.region.amazonaws.com/repositoryName)."
  value       = try(module.ecr[0].repository_url, null)
}

## ECR repo policy ##
output "ecr_repo_policy" {
  description = "policy - (Required) The policy document. This is a JSON formatted string."
  value       = try(module.ecr[0].repo_policy, null)
}

## ECR lifecycle policy ##
output "ecr_lifecycle_policy" {
  description = "policy - (Required) The policy document. This is a JSON formatted string."
  value       = try(module.ecr[0].lifecycle_policy, null)
}

## OIDC ##
output "oidc_provider_arn" {
  description = "OIDC provider ARN"
  value       = try(module.github-oidc[0].oidc_provider_arn, null)
}

output "oidc_role" {
  description = "CICD GitHub role."
  value       = try(module.github-oidc[0].oidc_role, null)
}