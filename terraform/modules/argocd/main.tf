resource "helm_release" "this" {
  name      = var.release_name
  namespace = var.namespace

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.chart_version

  create_namespace = true

  values = [
    file(var.values_file)
  ]
}