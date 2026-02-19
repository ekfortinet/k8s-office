# -----------------------------------------------------------------------------
# Namespaces (Variabel-drevet)
#
# Oprettes automatisk baseret på var.namespaces.
# Tilføj/fjern namespaces i variablerne → Terraform opretter/sletter dem.
# -----------------------------------------------------------------------------

resource "kubernetes_namespace" "ns" {
  for_each = var.namespaces

  metadata {
    name = each.key

    labels = merge(
      {
        "app.kubernetes.io/managed-by" = "terraform"
      },
      each.value.labels
    )
  }
}
