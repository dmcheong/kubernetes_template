resource "helm_release" "this" {
  name      = var.release_name
  namespace = var.namespace

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.chart_version

  create_namespace = true

  timeout = 600
  wait    = true
  atomic  = false

  values = [
    file(var.values_file)
  ]
}