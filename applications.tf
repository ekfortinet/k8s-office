# -----------------------------------------------------------------------------
# Applikationer (Variabel-drevet)
#
# Oprettes automatisk baseret på var.applications.
# Tilføj/fjern en app i variablerne → Terraform opretter/sletter den.
#
# VIGTIG: Pods labels med "egress-gateway/name" = <gateway-navn>
#         Cilium EgressGatewayPolicy matcher pods via dette label
#         og router deres udgående trafik via den rette gateway-node.
# -----------------------------------------------------------------------------

# Validering: Tjek at alle apps refererer til en eksisterende egress gateway
locals {
  invalid_egress_refs = {
    for app_name, app in var.applications :
    app_name => app.egress_gateway_name
    if !contains(keys(var.egress_gateways), app.egress_gateway_name)
  }
}

resource "terraform_data" "validate_egress_refs" {
  count = length(local.invalid_egress_refs) > 0 ? 1 : 0

  lifecycle {
    precondition {
      condition     = length(local.invalid_egress_refs) == 0
      error_message = <<-EOT
        Følgende applikationer refererer til egress gateways der ikke findes:
        ${jsonencode(local.invalid_egress_refs)}
        
        Tilgængelige egress gateways: ${jsonencode(keys(var.egress_gateways))}
      EOT
    }
  }
}

# Opret applikationer via modulet
module "application" {
  source   = "./modules/application"
  for_each = var.applications

  name                = each.key
  namespace           = each.value.namespace
  image               = each.value.image
  replicas            = each.value.replicas
  container_port      = each.value.container_port
  service_port        = each.value.service_port
  env_vars            = each.value.env_vars
  resource_limits     = each.value.resource_limits
  resource_requests   = each.value.resource_requests
  egress_gateway_name = each.value.egress_gateway_name
  labels              = each.value.labels
  annotations         = each.value.annotations
  node_selector       = each.value.node_selector
  volumes             = each.value.volumes

  depends_on = [
    kubernetes_namespace.ns,
    module.egress_gateway
  ]
}
