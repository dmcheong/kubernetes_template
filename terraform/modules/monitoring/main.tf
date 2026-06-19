resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_secret" "grafana_admin" {
  metadata {
    name      = var.grafana_admin_secret_name
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  data = {
    admin-user     = var.grafana_admin_user
    admin-password = var.grafana_admin_password
  }

  type = "Opaque"
}

resource "helm_release" "this" {
  name      = var.release_name
  namespace = kubernetes_namespace.this.metadata[0].name

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.chart_version

  create_namespace = false

  timeout = 600
  wait    = true
  atomic  = false

  values = [
    file(var.values_file)
  ]

  depends_on = [
    kubernetes_secret.grafana_admin
  ]
}