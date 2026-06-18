output "platform_objects_validation_configmap" {
  description = "Validation ConfigMap created by platform-objects."
  value       = kubernetes_config_map.platform_objects_validation.metadata[0].name
}