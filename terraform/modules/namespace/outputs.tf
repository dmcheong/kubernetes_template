output "name" {
  description = "Nom du namespace créé"
  value       = kubernetes_namespace.this.metadata[0].name
}