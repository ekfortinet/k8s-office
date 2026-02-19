# -----------------------------------------------------------------------------
# Application Module – Main
#
# Opretter en komplet applikation i Kubernetes:
#   1. Deployment – Kører applikationens pods
#   2. Service    – Eksponerer applikationen internt i klyngen
#
# Pods labels med "egress-gateway/name" så Cilium EgressGatewayPolicy
# automatisk matcher og router deres udgående trafik via den rette gateway.
# -----------------------------------------------------------------------------

locals {
  common_labels = merge(
    {
      "app.kubernetes.io/name"       = var.name
      "app.kubernetes.io/managed-by" = "terraform"
      "egress-gateway/name"          = var.egress_gateway_name
    },
    var.labels
  )
}

# -----------------------------------------------------------------------------
# 1. Deployment
# -----------------------------------------------------------------------------
resource "kubernetes_deployment" "app" {
  metadata {
    name        = var.name
    namespace   = var.namespace
    labels      = local.common_labels
    annotations = var.annotations
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        "app.kubernetes.io/name" = var.name
      }
    }

    template {
      metadata {
        labels      = local.common_labels
        annotations = var.annotations
      }

      spec {
        # Node selector (f.eks. til at schedule på specific node)
        node_selector = length(var.node_selector) > 0 ? var.node_selector : null

        container {
          name  = var.name
          image = var.image

          port {
            container_port = var.container_port
            name           = "http"
            protocol       = "TCP"
          }

          dynamic "env" {
            for_each = var.env_vars
            content {
              name  = env.key
              value = env.value
            }
          }

          resources {
            limits = {
              cpu    = var.resource_limits.cpu
              memory = var.resource_limits.memory
            }
            requests = {
              cpu    = var.resource_requests.cpu
              memory = var.resource_requests.memory
            }
          }

          # Volume mounts
          dynamic "volume_mount" {
            for_each = var.volumes
            content {
              name       = volume_mount.value.name
              mount_path = volume_mount.value.mount_path
              read_only  = volume_mount.value.read_only
            }
          }

          liveness_probe {
            tcp_socket {
              port = var.container_port
            }
            initial_delay_seconds = 30
            period_seconds        = 20
          }

          readiness_probe {
            tcp_socket {
              port = var.container_port
            }
            initial_delay_seconds = 10
            period_seconds        = 10
          }
        }

        # PVC Volumes
        dynamic "volume" {
          for_each = var.volumes
          content {
            name = volume.value.name
            persistent_volume_claim {
              claim_name = volume.value.claim_name
            }
          }
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      spec[0].template[0].metadata[0].annotations["kubectl.kubernetes.io/restartedAt"]
    ]
  }
}

# -----------------------------------------------------------------------------
# 2. Service
# -----------------------------------------------------------------------------
resource "kubernetes_service" "app" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels    = local.common_labels
  }

  spec {
    selector = {
      "app.kubernetes.io/name" = var.name
    }

    port {
      name        = "http"
      port        = var.service_port
      target_port = var.container_port
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}
