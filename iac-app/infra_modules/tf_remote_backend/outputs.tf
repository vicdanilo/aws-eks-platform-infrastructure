## S3 ##
output "s3_bucket_id" {
  description = "The name of the table"
  value       = module.s3_bucket_terraform_remote_backend.s3_bucket_id
}

output "s3_bucket_arn" {
  description = "The arn of the table"
  value       = module.s3_bucket_terraform_remote_backend.s3_bucket_arn
}

## DynamoDB ##
output "dynamodb_id" {
  description = "The name of the table"
  value       = module.dynamodb_terraform_state_lock.id
}

output "dynamodb_arn" {
  description = "The arn of the table"
  value       = module.dynamodb_terraform_state_lock.arn
}
