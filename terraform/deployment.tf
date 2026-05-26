resource "kubernetes_deployment" "app" {

  metadata {

    name = var.app_name

    namespace = kubernetes_namespace.platform.metadata[0].name

    labels = {
      app = var.app_name
    }

  }

  spec {

    replicas = var.app_replicas

    selector {

      match_labels = {
        app = var.app_name
      }

    }

    template {

      metadata {

        labels = {
          app = var.app_name
        }

      }

      spec {

        container {

          name = var.app_name

          image = var.app_image

          port {

            container_port = var.container_port

          }

          resources {

            requests = {

              cpu = var.cpu_request

              memory = var.memory_request

            }

            limits = {

              cpu = var.cpu_limit

              memory = var.memory_limit

            }

          }

        }

      }

    }

  }

}