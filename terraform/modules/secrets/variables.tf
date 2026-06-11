variable "namespace" {
  type        = string
  description = "Namespace where the secret will be created"
}

variable "secret_name" {
  type        = string
  description = "Name of the Kubernetes Secret"
}

variable "type" {
  type        = string
  description = "Type of Kubernetes Secret"
  default     = "Opaque"
}

variable "data" {
  type        = map(string)
  description = "Secret data as key/value pairs"
  sensitive   = true
}

variable "labels" {
  type        = map(string)
  description = "Labels to apply to the secret"
  default     = {}
}