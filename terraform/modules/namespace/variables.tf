variable "name" {
  description = "Nom du namespace Kubernetes"
  type        = string
}

variable "environment" {
  description = "Nom de l'environnement"
  type        = string
}

variable "managed_by" {
  description = "Outil responsable de la ressource"
  type        = string
}