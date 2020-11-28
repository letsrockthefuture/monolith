locals {
  namespace      = var.namespace
  app            = var.app
  version        = var.app_version
  docker_image   = var.docker_image
  container_port = var.container_port
}

resource "kubernetes_namespace" "monolith_namespace" {
  metadata {
    annotations = {
      name = local.namespace
    }

    labels = {
      app = local.app
    }

    name = local.namespace
  }
}

resource "kubernetes_deployment" "monolith_deployment" {
  metadata {
    name      = local.app
    namespace = local.namespace
    labels = {
      app     = local.app
      version = local.version
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = local.app
      }
    }
    template {
      metadata {
        labels = {
          app     = local.app
          version = local.version
        }
      }
      spec {
        container {
          image = local.docker_image
          name  = local.app
          args  = ["-listen=:${local.container_port}", "-text=${local.app}"]

          port {
            container_port = local.container_port
          }

          resources {
            limits {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
          liveness_probe {
            http_get {
              path = "/"
              port = local.container_port
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_namespace.monolith_namespace
  ]
}

resource "kubernetes_service" "monolith_service" {
  metadata {
    name      = "${local.app}-service"
    namespace = local.namespace

    labels = {
      app = local.app
    }
  }

  spec {
    selector = {
      app = kubernetes_deployment.monolith_deployment.metadata.0.labels.app
    }

    type = "LoadBalancer"

    port {
      port = local.container_port
    }
  }

  depends_on = [
    kubernetes_namespace.monolith_namespace,
    kubernetes_deployment.monolith_deployment
  ]
}
