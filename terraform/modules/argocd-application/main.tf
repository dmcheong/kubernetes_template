resource "kubernetes_manifest" "this" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"

    metadata = {
      name      = var.name
      namespace = var.namespace

      labels = {
        managed_by = "terraform"
      }
    }

    spec = {
      project = var.project

      source = {
        repoURL        = var.repo_url
        targetRevision = var.target_revision
        path           = var.path
      }

      destination = {
        server    = var.destination_server
        namespace = var.destination_namespace
      }

      syncPolicy = {
        syncOptions = [
          "CreateNamespace=true"
        ]

        automated = var.auto_sync ? {
          prune    = var.prune
          selfHeal = var.self_heal
        } : null
      }
    }
  }
}