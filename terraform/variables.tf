variable "namespace_name" {
  description = "Nom du namespace Kubernetes à créer"
  type        = string
  default     = "platform"
}

variable "environment" {
  description = "Nom de l'environnement"
  type        = string
  default     = "local"
}

variable "managed_by" {
  description = "Outil responsable de la ressource"
  type        = string
  default     = "terraform"
}

variable "app_name" {
  description = "Nom application"
  type        = string
  default     = "nginx"
}

variable "app_image" {
  description = "Image conteneur"
  type        = string
  default     = "nginx:stable"
}

variable "app_replicas" {
  description = "Nombre de replicas"
  type        = number
  default     = 1
}

variable "container_port" {
  description = "Port conteneur"
  type        = number
  default     = 80
}

variable "service_port" {
  description = "Port service"
  type        = number
  default     = 80
}

variable "service_type" {
  description = "Type service Kubernetes"
  type        = string
  default     = "ClusterIP"
}

variable "cpu_request" {
  type    = string
  default = "100m"
}

variable "memory_request" {
  type    = string
  default = "128Mi"
}

variable "cpu_limit" {
  type    = string
  default = "250m"
}

variable "memory_limit" {
  type    = string
  default = "256Mi"
}

#########################################
# KONG
#########################################

variable "kong_enabled" {
  type    = bool
  default = true
}

variable "kong_namespace" {
  type    = string
  default = "kong"
}

variable "kong_chart_version" {
  type    = string
  default = "2.51.0"
}