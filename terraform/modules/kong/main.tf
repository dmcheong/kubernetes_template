resource "kubernetes_namespace" "this" {
  count = var.enabled ? 1 : 0

  metadata {
    name = var.namespace_name
  }
}

resource "helm_release" "this" {
  count = var.enabled ? 1 : 0

  name             = "kong"
  namespace        = var.namespace_name
  repository       = "https://charts.konghq.com"
  chart            = "kong"
  version          = var.chart_version
  create_namespace = false
  wait             = true
  timeout          = 600

  values = [
    file(var.values_file)
  ]

  depends_on = [
    kubernetes_namespace.this
  ]

  set = [
    {
      name  = "env.database"
      value = var.database
    },
    {
      name  = "env.pg_host"
      value = var.pg_host
    },
    {
      name  = "env.pg_database"
      value = var.pg_database
    },
    {
      name  = "env.pg_user"
      value = var.pg_user
    },
    {
      name  = "env.pg_password"
      value = var.pg_password
    }
  ]
}