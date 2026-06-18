module "nginx_demo" {
  source = "../../../modules/nginx-demo"

  namespace_name = var.namespace_name
  app_name       = var.app_name
  nginx_image    = var.nginx_image
  replicas       = var.replicas
  ingress_host   = var.ingress_host
}