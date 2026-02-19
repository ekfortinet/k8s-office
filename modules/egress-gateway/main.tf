# -----------------------------------------------------------------------------
# Cilium Egress Gateway Module – Main
#
# Opretter en CiliumEgressGatewayPolicy der:
#   - Vælger pods baseret på labels (egress-gateway/name = <gateway-navn>)
#   - Router deres udgående trafik via en bestemt node
#   - Bruger en specifik egress IP (nodens IP)
#
# Cilium EgressGatewayPolicy er cluster-scoped (ingen namespace).
# Pods matches via podSelector labels – alle apps der har
# label "egress-gateway/name" = "<gateway-navn>" routes via denne gateway.
# -----------------------------------------------------------------------------

locals {
  gateway_name = "egress-${var.name}"

  # Standard pod selector: match apps der er tilknyttet denne gateway
  default_pod_labels = {
    "egress-gateway/name" = var.name
  }

  # Merge med evt. ekstra pod selector labels
  pod_labels = merge(local.default_pod_labels, var.pod_selector_labels)

  common_labels = merge(
    {
      "app.kubernetes.io/managed-by" = "terraform"
      "app.kubernetes.io/part-of"    = "egress-gateway"
      "egress-gateway/name"          = var.name
    },
    var.labels
  )
}

# -----------------------------------------------------------------------------
# CiliumEgressGatewayPolicy
#
# Denne policy matcher pods via labels og router deres udgående
# trafik (til destination_cidrs) via den angivne gateway-node.
# -----------------------------------------------------------------------------
resource "kubectl_manifest" "egress_gateway_policy" {
  yaml_body = yamlencode({
    apiVersion = "cilium.io/v2"
    kind       = "CiliumEgressGatewayPolicy"
    metadata = {
      name   = local.gateway_name
      labels = local.common_labels
    }
    spec = {
      selectors = [
        {
          podSelector = {
            matchLabels = local.pod_labels
          }
        }
      ]

      destinationCIDRs = var.destination_cidrs

      egressGateway = {
        nodeSelector = {
          matchLabels = var.node_labels
        }
        egressIP = var.egress_ip
      }
    }
  })
}
