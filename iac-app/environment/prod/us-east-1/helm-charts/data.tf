# data "terraform_remote_state" "eks-infra" {
#   backend = "s3"

#   config = {
#     bucket = "s3-use1-tf-eks-infra-prod-backend"
#     key    = "tf-eks-infra/us-east-1/prod/terraform.tfstate"
#     region = "us-east-1"
#   }
# }

# Temp terraform state file. For testing 
data "terraform_remote_state" "eks-infra" {
  backend = "local"

  config = {
    path = "../eks-infra/terraform.tfstate"
  }
}

locals {
  tags = {
    Region      = "us-east-1"
    Environment = "prod"
    Application = "helm-charts"
    Terraform   = true
  }
}