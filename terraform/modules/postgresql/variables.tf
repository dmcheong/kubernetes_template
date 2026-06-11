variable "enabled" {
  type = bool
}

variable "namespace_name" {
  type = string
}

variable "release_name" {
  type = string
}

variable "chart_version" {
  type = string
}

variable "database_name" {
  type = string
}

variable "username" {
  type = string
}

variable "password" {
  type      = string
  sensitive = true
}