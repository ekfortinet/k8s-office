resource "kubernetes_deployment" "apps" {
  for_each   = local.applications
  depends_on = [kubernetes_namespace.app_namespaces]

  metadata {
    name      = each.key
    namespace = each.value.namespace
    labels = {
      app        = each.key
      managed-by = "terraform"
    }
  }

  spec {
    replicas = each.value.replicas

    selector {
      match_labels = {
        app = each.key
      }
    }

    template {
      metadata {
        labels = {
          app = each.key
        }
      }

      spec {
        # Spred pods ud på forskellige noder når replicas > 1
        dynamic "affinity" {
          for_each = each.value.replicas > 1 ? [1] : []
          content {
            pod_anti_affinity {
              preferred_during_scheduling_ignored_during_execution {
                weight = 100
                pod_affinity_term {
                  label_selector {
                    match_labels = {
                      app = each.key
                    }
                  }
                  topology_key = "kubernetes.io/hostname"
                }
              }
            }
          }
        }

        container {
          name  = each.key
          image = each.value.image

          port {
            container_port = each.value.port
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }
        }
      }
    }
  }
}