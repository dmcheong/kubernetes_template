module "platform_namespace" {
  source = "./modules/namespace"

  name        = var.namespace_name
  environment = var.environment
  managed_by  = var.managed_by
}

module "app" {
  source = "./modules/app"

  namespace_name = module.platform_namespace.name
  app_name       = var.app_name
  app_image      = var.app_image
  app_replicas   = var.app_replicas

  container_port = var.container_port
  service_port   = var.service_port
  service_type   = var.service_type

  cpu_request    = var.cpu_request
  memory_request = var.memory_request
  cpu_limit      = var.cpu_limit
  memory_limit   = var.memory_limit

  managed_by = var.managed_by
}

module "kong" {
  source = "./modules/kong"

  enabled        = var.kong_enabled
  namespace_name = var.kong_namespace
  chart_version  = var.kong_chart_version
  values_file    = "${path.module}/values/kong_values.yaml"

  database    = var.kong_database
  pg_host     = var.kong_pg_host
  pg_database = var.kong_pg_database
  pg_user     = var.kong_pg_user
  pg_password = var.kong_pg_password
}

module "postgresql" {
  source = "./modules/postgresql"

  enabled        = var.postgresql_enabled
  namespace_name = var.postgresql_namespace
  release_name   = var.postgresql_release_name
  chart_version  = var.postgresql_chart_version

  database_name = var.postgresql_database_name
  username      = var.postgresql_username
  password      = var.postgresql_password
}

module "ingress_controller" {
  source = "./modules/ingress-controller"

  namespace     = "ingress-nginx"
  release_name  = "ingress-nginx"
  chart_version = "4.12.1"
  values_file   = "${path.module}/values/ingress_nginx_values.yaml"
}

module "monitoring" {
  source = "./modules/monitoring"

  namespace     = "monitoring"
  release_name  = "monitoring"
  chart_version = "61.7.2"
  values_file   = "${path.module}/values/monitoring_values.yaml"
}

module "storage" {
  source = "./modules/storage"

  storage_class_name  = "local-standard"
  provisioner         = "k8s.io/minikube-hostpath"
  reclaim_policy      = "Delete"
  volume_binding_mode = "Immediate"
  set_as_default      = false
}

module "grafana_secret" {
  source = "./modules/secrets"

  namespace   = "monitoring"
  secret_name = "grafana-admin"

  data = {
    admin-user     = "admin"
    admin-password = "admin"
  }

  labels = {
    app = "grafana"
  }

  depends_on = [
    module.monitoring
  ]
}

module "argocd" {
  source = "./modules/argocd"

  namespace     = "argocd"
  release_name  = "argocd"
  chart_version = "9.5.20"
  values_file   = "${path.module}/values/argocd_values.yaml"

  depends_on = [
    module.ingress_controller,
    module.storage,
  ]
}

module "argocd_demo_app" {
  source = "./modules/argocd-application"

  name                  = "demo-app"
  namespace             = "argocd"
  repo_url              = "https://github.com/TON_USER/TON_REPO.git"
  target_revision       = "main"
  path                  = "kubernetes/demo-app"
  destination_namespace = "demo-app"

  auto_sync = false
  prune     = false
  self_heal = false

  depends_on = [
    module.argocd
  ]
}

module "cert_manager" {
  source = "./modules/cert-manager"

  namespace     = "cert-manager"
  release_name  = "cert-manager"
  chart_version = "v1.16.2"
  values_file   = "${path.module}/values/cert_manager_values.yaml"

  depends_on = [
    module.ingress_controller
  ]
}