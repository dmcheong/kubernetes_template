resource "kubernetes_namespace" "this" {
  count = var.enabled ? 1 : 0

  metadata {
    name = var.namespace_name
  }
}

resource "helm_release" "this" {
  count = var.enabled ? 1 : 0

  name             = var.release_name
  namespace        = var.namespace_name
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "postgresql"
  version          = var.chart_version
  create_namespace = false
  wait             = true
  timeout          = 600

  set = [
    {
      name  = "auth.database"
      value = var.database_name
    },
    {
      name  = "auth.username"
      value = var.username
    },
    {
      name  = "auth.password"
      value = var.password
    }
  ]

  depends_on = [
    kubernetes_namespace.this
  ]
}