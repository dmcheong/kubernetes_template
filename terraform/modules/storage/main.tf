resource "kubernetes_storage_class_v1" "this" {
  metadata {
    name = var.storage_class_name

    annotations = var.set_as_default ? {
      "storageclass.kubernetes.io/is-default-class" = "true"
    } : {}

    labels = {
      managed_by = "terraform"
    }
  }

  storage_provisioner = var.provisioner
  reclaim_policy      = var.reclaim_policy
  volume_binding_mode = var.volume_binding_mode
}