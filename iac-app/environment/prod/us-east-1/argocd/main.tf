########################################
# ArgoCD
########################################
module "argocd" {
  source = "../../../../infra_modules/argocd"

  cluster_name = local.cluster_name

}