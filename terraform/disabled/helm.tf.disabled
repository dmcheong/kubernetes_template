resource "helm_release" "nginx" {

  name = "nginx"

  namespace = kubernetes_namespace.platform.metadata[0].name

  create_namespace = false

  repository = "https://charts.bitnami.com/bitnami"

  chart = "nginx"

  version = "22.0.7"

}