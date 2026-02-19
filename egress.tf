# =============================================================================
# Cilium Egress Gateway Policies (Dynamisk via var.egress_gateways)
# =============================================================================
# Tilføj/fjern egress gateway konfigurationer i terraform.tfvars.
# Hvert entry mapper et namespace til en egress gateway node.
# =============================================================================

resource "kubernetes_manifest" "egress_gateway_policy" {
  for_each = var.egress_gateways

  manifest = {
    apiVersion = "cilium.io/v2"
    kind       = "CiliumEgressGatewayPolicy"

    metadata = {
      name = "egress-${each.key}"
    }

    spec = {
      # Vælg pods i det angivne namespace
      selectors = [
        {
          podSelector = {
            matchLabels = {
              "io.kubernetes.pod.namespace" = each.key
            }
          }
        }
      ]

      # Destinations (default: alt udgående trafik)
      destinationCIDRs = each.value.destination_cidrs

      # Egress gateway node
      egressGateway = {
        nodeSelector = {
          matchLabels = {
            "kubernetes.io/hostname" = each.value.egress_node_name
          }
        }
        interface = "eth0"
        egressIP  = each.value.egress_node_ip
      }
    }
  }

  depends_on = [
    helm_release.cilium,
  ]
}
