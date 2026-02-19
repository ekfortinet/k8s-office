# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------

output "namespaces" {
  description = "Oprettede namespaces"
  value       = { for k, v in kubernetes_namespace.ns : k => v.metadata[0].name }
}

output "egress_gateways" {
  description = "Oprettede Cilium egress gateways"
  value = {
    for k, v in module.egress_gateway : k => {
      gateway_name       = v.gateway_name
      egress_ip          = v.egress_ip
      node_labels        = v.node_labels
      destination_cidrs  = v.destination_cidrs
      pod_selector       = v.pod_selector_labels
    }
  }
}

output "applications" {
  description = "Oprettede applikationer med deres egress gateway tilknytning"
  value = {
    for k, v in module.application : k => {
      deployment_name = v.deployment_name
      service_name    = v.service_name
      namespace       = v.namespace
      egress_gateway  = v.egress_gateway_name
    }
  }
}
