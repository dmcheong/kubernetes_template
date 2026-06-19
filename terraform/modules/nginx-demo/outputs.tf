output "namespace_name" {
  description = "Namespace créé pour NGINX."
  value       = kubernetes_namespace.this.metadata[0].name
}

output "deployment_name" {
  description = "Nom du Deployment NGINX."
  value       = kubernetes_deployment.this.metadata[0].name
}

output "service_name" {
  description = "Nom du Service NGINX."
  value       = kubernetes_service.this.metadata[0].name
}

output "ingress_name" {
  description = "Nom de l'Ingress NGINX."
  value       = kubernetes_ingress_v1.this.metadata[0].name
}

output "ingress_host" {
  description = "Host utilisé par l'Ingress."
  value       = var.ingress_host
}