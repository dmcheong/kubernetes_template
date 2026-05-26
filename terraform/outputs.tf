output "namespace" {
  value = kubernetes_namespace.platform.metadata[0].name
}

output "deployment" {
  value = kubernetes_deployment.app.metadata[0].name
}

output "service" {
  value = kubernetes_service.app.metadata[0].name
}

output "image" {
  value = var.app_image
}

output "ingress_url" {
  value = "http://${var.app_name}.local"
}

output "kong_namespace" {
  value = var.kong_namespace
}

output "kong_release" {
  value = "kong"
}