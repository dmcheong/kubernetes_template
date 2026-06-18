output "namespace_name" {
  description = "Namespace applicatif déployé."
  value       = module.nginx_demo.namespace_name
}

output "deployment_name" {
  description = "Deployment applicatif déployé."
  value       = module.nginx_demo.deployment_name
}

output "service_name" {
  description = "Service applicatif déployé."
  value       = module.nginx_demo.service_name
}

output "ingress_name" {
  description = "Ingress applicatif déployé."
  value       = module.nginx_demo.ingress_name
}

output "ingress_host" {
  description = "Host local utilisé pour l'Ingress."
  value       = module.nginx_demo.ingress_host
}