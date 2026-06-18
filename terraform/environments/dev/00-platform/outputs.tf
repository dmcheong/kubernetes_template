output "namespace" {
  value = module.platform_namespace.name
}

output "deployment" {
  value = module.app.deployment_name
}

output "service" {
  value = module.app.service_name
}

output "ingress" {
  value = module.app.ingress_name
}

output "ingress_url" {
  value = "http://${module.app.ingress_host}"
}

output "image" {
  value = var.app_image
}

output "kong_namespace" {
  value = var.kong_namespace
}

output "kong_release" {
  value = "kong"
}

output "postgresql_namespace" {
  value = module.postgresql.namespace_name
}

output "postgresql_release" {
  value = module.postgresql.release_name
}

output "postgresql_service" {
  value = module.postgresql.service_name
}