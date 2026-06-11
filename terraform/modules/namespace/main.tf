resource "kubernetes_namespace" "this" {
  metadata {
    name = var.name

    labels = {
      managed_by  = var.managed_by
      environment = var.environment
    }
  }
}