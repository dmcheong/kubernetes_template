resource "kubernetes_config_map" "platform_objects_validation" {
  metadata {
    name      = "platform-objects-validation"
    namespace = "default"

    labels = {
      environment = var.environment
      managed_by  = "terraform"
      layer       = "platform-objects"
    }
  }

  data = {
    status  = "initialized"
    purpose = "Validate dev platform objects layer"
  }
}