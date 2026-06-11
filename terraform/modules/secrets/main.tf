resource "kubernetes_secret_v1" "this" {
  metadata {
    name      = var.secret_name
    namespace = var.namespace

    labels = merge(
      {
        managed_by = "terraform"
      },
      var.labels
    )
  }

  type = var.type

  data = var.data
}