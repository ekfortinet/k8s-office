# -----------------------------------------------------------------------------
# Egress Gateways – Cilium (Variabel-drevet)
#
# Oprettes automatisk baseret på var.egress_gateways.
# Tilføj/fjern en gateway i variablerne → Terraform opretter/sletter den.
#
# REGLER:
#   1. Alle apps SKAL have en egress gateway tildelt
#   2. En gateway kan deles af flere apps
#   3. Cilium matcher pods via label: egress-gateway/name = <gateway-navn>
# -----------------------------------------------------------------------------

module "egress_gateway" {
  source   = "./modules/egress-gateway"
  for_each = var.egress_gateways

  name              = each.key
  node_labels       = each.value.node_labels
  egress_ip         = each.value.egress_ip
  destination_cidrs = each.value.destination_cidrs
  labels            = each.value.labels
}
