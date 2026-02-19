# =============================================================================
# Kubeconfig
# =============================================================================

variable "kubeconfig_path" {
  description = "Sti til kubeconfig filen på k8s-master"
  type        = string
  default     = "~/.kube/config"
}

# =============================================================================
# Nodes
# =============================================================================

variable "nodes" {
  description = "Map af node-navne til IP-adresser"
  type        = map(string)
  default = {
    "k8s-master" = "10.200.0.11"
    "k8s-slave1" = "10.200.0.9"
    "k8s-slave2" = "10.200.0.10"
  }
}

# =============================================================================
# Applications (Source of Truth)
# =============================================================================

variable "applications" {
  description = <<-EOT
    Source of truth for alle applikationer i klyngen.
    Tilføj/fjern entries for at installere/afinstallere applikationer.
  EOT

  type = map(object({
    namespace   = string
    helm_repo   = string
    helm_chart  = string
    chart_version = optional(string)
    values      = optional(map(string), {})
    set_values  = optional(list(object({
      name  = string
      value = string
    })), [])
  }))

  default = {}
}

# =============================================================================
# Egress Gateways (Source of Truth)
# =============================================================================

variable "egress_gateways" {
  description = <<-EOT
    Source of truth for Cilium egress gateway policies.
    Definerer hvilke namespaces der bruger hvilke egress gateways (noder).
  EOT

  type = map(object({
    egress_node_name = string
    egress_node_ip   = string
    destination_cidrs = optional(list(string), ["0.0.0.0/0"])
  }))

  default = {}
}
