variable "namespace" {
  type        = string
  description = "Namespace where ingress-nginx will be installed"
}

variable "release_name" {
  type        = string
  description = "Helm release name"
  default     = "ingress-nginx"
}

variable "chart_version" {
  type        = string
  description = "Ingress NGINX Helm chart version"
}

variable "values_file" {
  type        = string
  description = "Path to the Helm values file"
}