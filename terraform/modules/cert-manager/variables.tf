variable "namespace" {
  type        = string
  description = "Namespace where cert-manager will be installed"
}

variable "release_name" {
  type        = string
  description = "Helm release name"
  default     = "cert-manager"
}

variable "chart_version" {
  type        = string
  description = "cert-manager Helm chart version"
}

variable "values_file" {
  type        = string
  description = "Path to the Helm values file"
}