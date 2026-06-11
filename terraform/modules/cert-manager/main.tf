resource "helm_release" "this" {
  name      = var.release_name
  namespace = var.namespace

  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = var.chart_version

  create_namespace = true

  values = [
    file(var.values_file)
  ]
}