output "secret_name" {
  value = kubernetes_secret_v1.this.metadata[0].name
}

output "namespace" {
  value = kubernetes_secret_v1.this.metadata[0].namespace
}

output "type" {
  value = kubernetes_secret_v1.this.type
}