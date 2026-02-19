# =============================================================================
# K8s Office - Main Orchestration
# =============================================================================
# Denne fil opretter namespaces for alle applikationer.
# Applikationer og egress gateways styres via variables.
# =============================================================================

# Opret namespaces for hver applikation
resource "kubernetes_namespace" "app_namespaces" {
  for_each = var.applications

  metadata {
    name = each.value.namespace

    labels = {
      "managed-by" = "terraform"
      "app"        = each.key
    }
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
    ]
  }
}
