# -----------------------------------------------------------------------------
# Application Module – Outputs
# -----------------------------------------------------------------------------

output "deployment_name" {
  description = "Navnet på den oprettede Deployment"
  value       = kubernetes_deployment.app.metadata[0].name
}

output "service_name" {
  description = "Navnet på den oprettede Service"
  value       = kubernetes_service.app.metadata[0].name
}

output "namespace" {
  description = "Namespace hvor applikationen kører"
  value       = var.namespace
}

output "egress_gateway_name" {
  description = "Egress gateway som applikationen er tilknyttet"
  value       = var.egress_gateway_name
}
