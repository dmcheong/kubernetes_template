variable "namespace" {
  type        = string
  description = "Namespace where monitoring stack will be installed"
}

variable "release_name" {
  type        = string
  description = "Helm release name"
  default     = "monitoring"
}

variable "chart_version" {
  type        = string
  description = "kube-prometheus-stack chart version"
}

variable "values_file" {
  type        = string
  description = "Path to the Helm values file"
}

variable "grafana_admin_secret_name" {
  type    = string
  default = "grafana-admin"
}

variable "grafana_admin_user" {
  type    = string
  default = "admin"
}

variable "grafana_admin_password" {
  type      = string
  sensitive = true
}