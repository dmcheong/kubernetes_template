variable "enabled" {
  type = bool
}

variable "namespace_name" {
  type = string
}

variable "chart_version" {
  type = string
}

variable "values_file" {
  type = string
}

variable "database" {
  type = string
}

variable "pg_host" {
  type = string
}

variable "pg_database" {
  type = string
}

variable "pg_user" {
  type = string
}

variable "pg_password" {
  type      = string
  sensitive = true
}