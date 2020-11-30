locals {
  app            = var.app
  namespace      = var.namespace
  version        = var.app_version
  replicas       = var.replicas
  docker_image   = var.docker_image
  container_port = var.container_port
}

resource "kubernetes_namespace" "monolith_namespace" {
  metadata {
    annotations = {
      name = local.namespace
    }

    labels = {
      app             = local.app
      istio-injection = "enabled"
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
    replicas = local.replicas
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
          args  = ["-listen=:${local.container_port}", "-text=Service: ${local.app}.${local.app}.svc.cluster.local"]

          port {
            container_port = local.container_port
          }

          resources {
            requests {
              cpu    = "25m"
              memory = "64Mi"
            }
            limits {
              cpu    = "50m"
              memory = "128Mi"
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
        node_selector = {
          "app" = local.app
        }
      }
    }
  }

  depends_on = [
    kubernetes_namespace.monolith_namespace
  ]
}

resource "kubernetes_service" "monolith_private_service" {
  metadata {
    name      = local.app
    namespace = local.namespace

    labels = {
      app = local.app
    }
  }

  spec {
    selector = {
      app = kubernetes_deployment.monolith_deployment.metadata.0.labels.app
    }

    type = "ClusterIP"

    port {
      port = local.container_port
    }
  }

  depends_on = [
    kubernetes_namespace.monolith_namespace,
    kubernetes_deployment.monolith_deployment
  ]
}

resource "kubernetes_service" "monolith_public_service" {
  metadata {
    name      = "${local.app}-public"
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
