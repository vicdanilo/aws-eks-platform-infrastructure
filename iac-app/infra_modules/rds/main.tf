module "db_instance" {
  count = var.create_rds ? 1 : 0
  
  source = "terraform-aws-modules/rds/aws"
  version = "~> 6.10"

  identifier = var.identifier

  # RDS configuration
  engine            = var.engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  family            = var.family
  parameters        = var.parameters
  storage_type      = var.storage_type
  storage_encrypted = var.storage_encrypted

  # Cloudwatch parameters
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  create_cloudwatch_log_group     = var.create_cloudwatch_log_group
  create_monitoring_role          = var.create_monitoring_role

  # DB configuration
  db_name  = var.db_name
  username = var.username
  port     = var.port

  # IAM, security and networking
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  deletion_protection                 = var.deletion_protection
  vpc_security_group_ids              = var.vpc_security_group_ids
  db_subnet_group_name                = var.db_subnet_group_name

  options = var.options
  tags    = var.tags
}