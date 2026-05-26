resource "kubernetes_ingress_v1" "app" {

  metadata {

    name = "${var.app_name}-ingress"

    namespace = kubernetes_namespace.platform.metadata[0].name

    annotations = {

      "nginx.ingress.kubernetes.io/rewrite-target" = "/"

    }

  }

  spec {

    ingress_class_name = "nginx"

    rule {

      host = "${var.app_name}.local"

      http {

        path {

          path = "/"

          path_type = "Prefix"

          backend {

            service {

              name = kubernetes_service.app.metadata[0].name

              port {

                number = var.service_port

              }

            }

          }

        }

      }

    }

  }

}