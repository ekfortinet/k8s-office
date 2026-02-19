# -----------------------------------------------------------------------------
# Cilium Egress Gateway Module – Outputs
# -----------------------------------------------------------------------------

output "gateway_name" {
  description = "Navnet på den oprettede CiliumEgressGatewayPolicy"
  value       = local.gateway_name
}

output "egress_ip" {
  description = "IP-adressen som udgående trafik bruger"
  value       = var.egress_ip
}

output "node_labels" {
  description = "Labels der vælger gateway-noden"
  value       = var.node_labels
}

output "destination_cidrs" {
  description = "Destination CIDRs som routes via denne gateway"
  value       = var.destination_cidrs
}

output "pod_selector_labels" {
  description = "Labels der bruges til at matche pods"
  value       = local.pod_labels
}
