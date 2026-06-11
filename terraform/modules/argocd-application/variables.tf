variable "name" {
  type        = string
  description = "Name of the ArgoCD Application"
}

variable "namespace" {
  type        = string
  description = "Namespace where the ArgoCD Application resource is created"
  default     = "argocd"
}

variable "project" {
  type        = string
  description = "ArgoCD project"
  default     = "default"
}

variable "repo_url" {
  type        = string
  description = "Git repository URL"
}

variable "target_revision" {
  type        = string
  description = "Git target revision"
  default     = "HEAD"
}

variable "path" {
  type        = string
  description = "Path inside the Git repository"
}

variable "destination_server" {
  type        = string
  description = "Kubernetes API server destination"
  default     = "https://kubernetes.default.svc"
}

variable "destination_namespace" {
  type        = string
  description = "Namespace where the app will be deployed"
}

variable "auto_sync" {
  type        = bool
  description = "Enable automated sync"
  default     = false
}

variable "prune" {
  type        = bool
  description = "Allow ArgoCD to delete resources no longer tracked in Git"
  default     = false
}

variable "self_heal" {
  type        = bool
  description = "Allow ArgoCD to restore drift automatically"
  default     = false
}