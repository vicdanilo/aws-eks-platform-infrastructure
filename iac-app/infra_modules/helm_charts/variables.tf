## argocd ##
variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "provider_url" {
  description = "The OIDC provider URL"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}