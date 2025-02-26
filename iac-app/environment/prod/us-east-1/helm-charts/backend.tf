# terraform {
#   backend "s3" {
#     bucket         = "s3-use1-tf-eks-infra-prod-backend"
#     region         = "us-east-1"
#     key            = "tf-eks-infra/us-east-1/prod/helm_charts/terraform.tfstate"
#     dynamodb_table = "dynamo-use1-tf-eks-infra-prod-terraform-state-lock"
#     encrypt        = true
#   }
# }
