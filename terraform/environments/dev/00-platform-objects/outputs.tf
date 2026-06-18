output "namespace_name" {
  description = "Namespace créé pour les objets applicatifs."
  value       = kubernetes_namespace.demo.metadata[0].name
}

output "service_name" {
  description = "Service Kubernetes NGINX."
  value       = kubernetes_service.nginx.metadata[0].name
}

output "deployment_name" {
  description = "Deployment Kubernetes NGINX."
  value       = kubernetes_deployment.nginx.metadata[0].name
}

output "ingress_host" {
  description = "Host local utilisé par l'Ingress NGINX."
  value       = var.ingress_host
}

output "ingress_name" {
  description = "Nom de l'Ingress Kubernetes créé."
  value       = kubernetes_ingress_v1.nginx.metadata[0].name
}