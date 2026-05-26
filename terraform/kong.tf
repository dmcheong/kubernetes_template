resource "kubernetes_namespace" "kong" {
  count = var.kong_enabled ? 1 : 0

  metadata {
    name = var.kong_namespace
  }
}

resource "helm_release" "kong" {
  count = var.kong_enabled ? 1 : 0

  name             = "kong"
  namespace        = var.kong_namespace
  repository       = "https://charts.konghq.com"
  chart            = "kong"
  version          = var.kong_chart_version
  create_namespace = false
  wait             = true
  timeout          = 600

  values = [
    file("${path.module}/values/kong_values.yaml")
  ]

  depends_on = [
    kubernetes_namespace.kong
  ]
}