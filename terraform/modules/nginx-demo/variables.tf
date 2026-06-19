variable "namespace_name" {
  description = "Namespace applicatif de démonstration."
  type        = string
}

variable "app_name" {
  description = "Nom de l'application NGINX de démonstration."
  type        = string
}

variable "nginx_image" {
  description = "Image Docker utilisée pour NGINX."
  type        = string
}

variable "replicas" {
  description = "Nombre de replicas NGINX."
  type        = number
}

variable "ingress_host" {
  description = "Nom DNS local utilisé pour exposer NGINX via Ingress."
  type        = string
}