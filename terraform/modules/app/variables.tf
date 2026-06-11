variable "namespace_name" {
  type = string
}

variable "app_name" {
  type = string
}

variable "app_image" {
  type = string
}

variable "app_replicas" {
  type = number
}

variable "container_port" {
  type = number
}

variable "service_port" {
  type = number
}

variable "service_type" {
  type = string
}

variable "cpu_request" {
  type = string
}

variable "memory_request" {
  type = string
}

variable "cpu_limit" {
  type = string
}

variable "memory_limit" {
  type = string
}

variable "managed_by" {
  type = string
}