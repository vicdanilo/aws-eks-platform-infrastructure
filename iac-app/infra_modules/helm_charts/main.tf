# resource "helm_release" "aws_load_balancer_controller" {
  
#   name = "aws-load-balancer-controller"

#   repository       = "https://aws.github.io/eks-charts"
#   chart            = "aws-load-balancer-controller"
#   namespace        = "kube-system"
#   version          = "7.3.11"

#   values = [file("values/aws-loadbalancer-controller.yaml")] # if fails try to use the full path

#   depends_on = [helm_release.aws_load_balancer_controller]

# }

resource "helm_release" "alb_service_account" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = var.alb_svc_role
  }
}
