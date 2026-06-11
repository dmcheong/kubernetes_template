variable "storage_class_name" {
  type        = string
  description = "Name of the Kubernetes StorageClass"
  default     = "local-standard"
}

variable "provisioner" {
  type        = string
  description = "Storage provisioner used by the StorageClass"
  default     = "k8s.io/minikube-hostpath"
}

variable "reclaim_policy" {
  type        = string
  description = "Reclaim policy for persistent volumes"
  default     = "Delete"
}

variable "volume_binding_mode" {
  type        = string
  description = "Volume binding mode for persistent volumes"
  default     = "Immediate"
}

variable "set_as_default" {
  type        = bool
  description = "Whether this StorageClass should be the default one"
  default     = false
}