output "namespace_name" {
  value = var.namespace_name
}

output "release_name" {
  value = var.release_name
}

output "service_name" {
  value = "${var.release_name}-postgresql"
}

output "database_name" {
  value = var.database_name
}

output "username" {
  value = var.username
}