# =============================================================================
# Application Deployments (Dynamisk via var.applications)
# =============================================================================
# Tilføj/fjern applikationer i terraform.tfvars for at ændre hvad der kører.
# Terraform håndterer automatisk installation og fjernelse.
# =============================================================================

resource "helm_release" "applications" {
  for_each = var.applications

  name       = each.key
  namespace  = each.value.namespace
  repository = each.value.helm_repo
  chart      = each.value.helm_chart
  version    = each.value.chart_version

  # Dynamiske set-values
  dynamic "set" {
    for_each = each.value.set_values
    content {
      name  = set.value.name
      value = set.value.value
    }
  }

  # Vent på at applikationen er klar
  wait             = true
  timeout          = 300
  create_namespace = false

  depends_on = [
    kubernetes_namespace.app_namespaces,
    helm_release.cilium,
  ]
}
