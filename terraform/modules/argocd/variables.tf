variable "namespace" {
  type        = string
  description = "Namespace where ArgoCD will be installed"
}

variable "release_name" {
  type        = string
  description = "Helm release name"
  default     = "argocd"
}

variable "chart_version" {
  type        = string
  description = "ArgoCD Helm chart version"
}

variable "values_file" {
  type        = string
  description = "Path to the Helm values file"
}