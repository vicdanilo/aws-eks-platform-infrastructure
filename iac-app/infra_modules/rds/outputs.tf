output "db_instance_address" {
  description = "The address of the RDS instance"
  value       = try(module.db_instance[0].db_instance_address, null)
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = try(module.db_instance[0].db_instance_arn, null)
}

output "db_instance_availability_zone" {
  description = "The availability zone of the RDS instance"
  value       = try(module.db_instance[0].db_instance_availability_zone, null)
}

output "db_instance_endpoint" {
  description = "The connection endpoint"
  value       = try(module.db_instance[0].db_instance_endpoint, null)
}

output "db_listener_endpoint" {
  description = "Specifies the listener connection endpoint for SQL Server Always On"
  value       = try(module.db_instance[0].db_listener_endpoint, null)
}

output "db_instance_identifier" {
  description = "The RDS instance identifier"
  value       = try(module.db_instance[0].db_instance_identifier, null)
}

output "db_instance_name" {
  description = "The database name"
  value       = try(module.db_instance[0].db_instance_name, null)
}

output "db_instance_username" {
  description = "The master username for the database"
  value       = try(module.db_instance[0].db_instance_username, null)
  sensitive   = true
}

output "db_instance_domain" {
  description = "The ID of the Directory Service Active Directory domain the instance is joined to"
  value       = try(module.db_instance[0].db_instance_domain, null)
}

output "db_instance_domain_fqdn" {
  description = "The fully qualified domain name (FQDN) of an self managed Active Directory domain"
  value       = try(module.db_instance[0].db_instance_domain_fqdn, null)
}

output "db_instance_domain_iam_role_name" {
  description = "The name of the IAM role to be used when making API calls to the Directory Service"
  value       = try(module.db_instance[0].db_instance_domain_iam_role_name, null)
}

output "db_instance_port" {
  description = "The database port"
  value       = try(module.db_instance[0].db_instance_port, null)
}

output "db_instance_ca_cert_identifier" {
  description = "Specifies the identifier of the CA certificate for the DB instance"
  value       = try(module.db_instance[0].db_instance_ca_cert_identifier, null)
}

output "db_instance_master_user_secret_arn" {
  description = "The ARN of the master user secret (Only available when manage_master_user_password is set to true)"
  value       = try(module.db_instance[0].db_instance_master_user_secret_arn, null)
}

# DB option group
output "db_option_group_id" {
  description = "The db option group id"
  value       = try(module.db_instance[0].db_option_group_id, null)
}

output "db_option_group_arn" {
  description = "The ARN of the db option group"
  value       = try(module.db_instance[0].db_option_group_arn, null)
}

################################################################################
# CloudWatch Log Group
################################################################################

output "db_instance_cloudwatch_log_groups" {
  description = "Map of CloudWatch log groups created and their attributes"
  value       = try(module.db_instance[0].db_instance_cloudwatch_log_groups, null)
}

################################################################################
# DB Instance Role Association
################################################################################

output "db_instance_role_associations" {
  description = "A map of DB Instance Identifiers and IAM Role ARNs separated by a comma"
  value       = try(module.db_instance[0].db_instance_role_associations, null)
}

################################################################################
# Managed Secret Rotation
################################################################################

output "db_instance_secretsmanager_secret_rotation_enabled" {
  description = "Specifies whether automatic rotation is enabled for the secret"
  value       = try(module.db_instance[0].db_instance_secretsmanager_secret_rotation_enabled, null)
}