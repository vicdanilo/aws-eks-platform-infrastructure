########################################
# Helm Charts
########################################
module "helm_charts" {
  source = "../../../../infra_modules/helm_charts"

  cluster_name = data.terraform_remote_state.eks-infra.outputs.eks_cluster_name

  ## alb ##
  provider_url = data.terraform_remote_state.eks-infra.outputs.eks_cluster_oidc_issuer_url

  tags = local.tags
}