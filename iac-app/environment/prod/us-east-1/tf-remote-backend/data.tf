########################################
# Data sources
########################################

# Computed variables
locals {
  tags = {
    Region      = var.region
    Environment = var.env
    Application = var.app_name
    Terraform   = true
  }
}