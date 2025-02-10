## S3 ##
output "s3_terraform_remote_backend_id" {
  description = "The name of the table"
  value       = module.tf_remote_backend.s3_bucket_id
}

output "s3_terraform_remote_backend_arn" {
  description = "The arn of the table"
  value       = module.tf_remote_backend.s3_bucket_arn
}

## DynamoDB ##
output "dynamodb_terraform_state_lock_id" {
  description = "The name of the table"
  value       = module.tf_remote_backend.dynamodb_id
}

output "dynamodb_terraform_state_lock_arn" {
  description = "The arn of the table"
  value       = module.tf_remote_backend.dynamodb_arn
}
