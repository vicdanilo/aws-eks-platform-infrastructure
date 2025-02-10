## argocd ##
variable "cluster_name" {
    description = "The name of the EKS cluster"
    type        = string
}

variable "alb_svc_role" {
    description = "The ARN of the IAM role for the ALB service account"
    type        = string
}