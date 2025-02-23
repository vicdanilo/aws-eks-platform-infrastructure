## ECR ##
variable "create_ecr" {
  type    = bool
  default = false
}

variable "create_github_oidc" {
  type    = bool
  default = true
}

variable "ecr_name" {
  type = string
  description = "Name of the repository"
}

variable "ecr_image_tag_mutability" {
  type = string
  description = "The tag mutability setting for the repository. Must be one of: MUTABLE or IMMUTABLE. Defaults to MUTABLE."
}

variable "tags" {
  type = map(string)
  description = "Tags to apply to the ECR Repository."
}

variable "github_repository" {
  type        = string
  description = "The name of the GitHub repository"
}

variable "worker_role_arn" {
  type        = string
  description = "The ARN of the Worker IAM role to allow pulling images from the ECR repository"
}

variable "region_tag" {
  type = map(any)

  default = {
    "us-east-1" = "use1"
    "us-east-2" = "use2"
    "us-west-1" = "usw1"
  }
}