resource "kubernetes_namespace" "platform" {
  metadata {
    name = var.namespace_name

    labels = {
      managed_by  = var.managed_by
      environment = var.environment
    }
  }
}