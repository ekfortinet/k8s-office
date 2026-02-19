# =============================================================================
# K8s Office - Terraform Variables
# =============================================================================
# Dette er source of truth for alle applikationer og egress gateways.
# Ændr denne fil og push til main for at opdatere klyngen.
# =============================================================================

kubeconfig_path = "~/.kube/config"

# =============================================================================
# Nodes
# =============================================================================

nodes = {
  "k8s-master" = "10.200.0.11"
  "k8s-slave1" = "10.200.0.9"
  "k8s-slave2" = "10.200.0.10"
}

# =============================================================================
# Applications (Source of Truth)
# =============================================================================
# Tilføj en applikation her for at deploye den.
# Fjern en applikation for at afinstallere den.
# =============================================================================

applications = {
  n8n = {
    namespace     = "n8n"
    helm_repo     = "oci://8gears.container-registry.com/library"
    helm_chart    = "n8n"
    chart_version = "0.25.2"
    set_values = [
      { name = "service.type", value = "ClusterIP" },
      { name = "persistence.enabled", value = "true" },
      { name = "persistence.size", value = "5Gi" },
    ]
  }
}

# =============================================================================
# Egress Gateways (Source of Truth)
# =============================================================================
# Definer hvilke namespaces der skal bruge en egress gateway.
# Key = namespace navn, value = egress node info.
# =============================================================================

egress_gateways = {
  n8n = {
    egress_node_name  = "k8s-slave1"
    egress_node_ip    = "10.200.0.9"
    destination_cidrs = ["0.0.0.0/0"]
  }
}
