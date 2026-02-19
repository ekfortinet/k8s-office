# -----------------------------------------------------------------------------
# Global Variables
# -----------------------------------------------------------------------------

variable "kubeconfig_path" {
  description = "Sti til kubeconfig filen for at tilgå klyngen"
  type        = string
  default     = "~/.kube/config"
}

variable "kubeconfig_context" {
  description = "Kubernetes context som skal bruges. Tom streng = brug current-context fra kubeconfig"
  type        = string
  default     = ""
}

variable "cluster_name" {
  description = "Navn på Kubernetes klyngen"
  type        = string
  default     = "k8s-office"
}

# -----------------------------------------------------------------------------
# Egress Gateways (Cilium)
#
# Definér alle egress gateways her. Nøglen er gateway-navnet.
# En egress gateway router udgående trafik via en bestemt node og IP.
# Flere applikationer kan dele den samme egress gateway.
#
# Cilium EgressGatewayPolicy kræver:
#   - node_labels: Vælger hvilken node der bruges som egress gateway
#   - egress_ip:   Den IP trafik udgår fra (nodens IP)
#   - destination_cidrs: Hvilke destinationer der routes via gateway
# -----------------------------------------------------------------------------
variable "egress_gateways" {
  description = "Map af Cilium egress gateways. Nøglen er det unikke gateway-navn."
  type = map(object({
    node_labels = map(string)        # Labels til at vælge gateway-noden
    egress_ip   = string             # IP-adresse som udgående trafik bruger
    destination_cidrs = optional(list(string), ["0.0.0.0/0"])  # Default: al udgående trafik
    labels      = optional(map(string), {})
  }))
  default = {}
}

# -----------------------------------------------------------------------------
# Applikationer
#
# Definér alle applikationer her. Nøglen er app-navnet.
# Når du tilføjer/fjerner en app her, oprettes/slettes den i Kubernetes.
#
# REGEL: Hver app SKAL referere til en egress_gateway_name der findes
#        i egress_gateways variablen ovenfor.
# -----------------------------------------------------------------------------
variable "applications" {
  description = "Map af applikationer der skal deployes. Nøglen er app-navnet."
  type = map(object({
    namespace           = string
    egress_gateway_name = string         # Skal matche en nøgle i egress_gateways
    image               = string         # Container image
    replicas            = optional(number, 1)
    container_port      = optional(number, 80)
    service_port        = optional(number, 80)
    env_vars            = optional(map(string), {})
    resource_limits = optional(object({
      cpu    = optional(string, "250m")
      memory = optional(string, "256Mi")
    }), { cpu = "250m", memory = "256Mi" })
    resource_requests = optional(object({
      cpu    = optional(string, "100m")
      memory = optional(string, "128Mi")
    }), { cpu = "100m", memory = "128Mi" })
    labels      = optional(map(string), {})
    annotations = optional(map(string), {})
    node_selector = optional(map(string), {})
    volumes = optional(list(object({
      name           = string
      claim_name     = string
      mount_path     = string
      read_only      = optional(bool, false)
    })), [])
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.applications : can(regex("^[a-z0-9-]+$", k))
    ])
    error_message = "App-navne må kun indeholde lowercase bogstaver, tal og bindestreger."
  }
}

# -----------------------------------------------------------------------------
# Namespaces
# -----------------------------------------------------------------------------
variable "namespaces" {
  description = "Map af namespaces der skal oprettes. Nøglen er namespace-navnet."
  type = map(object({
    labels = optional(map(string), {})
  }))
  default = {
    apps = {}
  }
}
