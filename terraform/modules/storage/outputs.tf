output "storage_class_name" {
  value = kubernetes_storage_class_v1.this.metadata[0].name
}

output "provisioner" {
  value = kubernetes_storage_class_v1.this.storage_provisioner
}

output "reclaim_policy" {
  value = kubernetes_storage_class_v1.this.reclaim_policy
}