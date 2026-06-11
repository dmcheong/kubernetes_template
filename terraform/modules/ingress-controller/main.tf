resource "helm_release" "this" {
  name      = var.release_name
  namespace = var.namespace

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = var.chart_version

  create_namespace = true

  values = [
    file(var.values_file)
  ]
}