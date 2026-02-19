# =============================================================================
# Outputs
# =============================================================================

output "deployed_applications" {
  description = "Liste over deployede applikationer"
  value = {
    for name, app in var.applications : name => {
      namespace = app.namespace
      chart     = app.helm_chart
    }
  }
}

output "egress_gateway_policies" {
  description = "Liste over konfigurerede egress gateway policies"
  value = {
    for ns, gw in var.egress_gateways : ns => {
      egress_node = gw.egress_node_name
      egress_ip   = gw.egress_node_ip
      cidrs       = gw.destination_cidrs
    }
  }
}

output "cilium_version" {
  description = "Installeret Cilium version"
  value       = helm_release.cilium.version
}
