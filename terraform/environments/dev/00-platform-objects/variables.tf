variable "namespace_name" {
  description = "Namespace applicatif de démonstration."
  type        = string
  default     = "demo"
}

variable "app_name" {
  description = "Nom de l'application de démonstration."
  type        = string
  default     = "nginx-demo"
}

variable "nginx_image" {
  description = "Image Docker utilisée pour NGINX."
  type        = string
  default     = "nginx:1.27-alpine"
}

variable "replicas" {
  description = "Nombre de replicas NGINX."
  type        = number
  default     = 1
}