# -----------------------------------------------------------------------------
# Application Module – Variables
# -----------------------------------------------------------------------------

variable "name" {
  description = "Applikationens navn"
  type        = string
}

variable "namespace" {
  description = "Namespace hvor applikationen deployes"
  type        = string
}

variable "image" {
  description = "Container image (f.eks. nginx:1.25)"
  type        = string
}

variable "replicas" {
  description = "Antal replicas"
  type        = number
  default     = 1
}

variable "container_port" {
  description = "Port som containeren lytter på"
  type        = number
  default     = 80
}

variable "service_port" {
  description = "Port som Kubernetes Service eksponerer"
  type        = number
  default     = 80
}

variable "env_vars" {
  description = "Environment variabler til containeren"
  type        = map(string)
  default     = {}
}

variable "resource_limits" {
  description = "Resource limits for containeren"
  type = object({
    cpu    = string
    memory = string
  })
  default = {
    cpu    = "250m"
    memory = "256Mi"
  }
}

variable "resource_requests" {
  description = "Resource requests for containeren"
  type = object({
    cpu    = string
    memory = string
  })
  default = {
    cpu    = "100m"
    memory = "128Mi"
  }
}

variable "egress_gateway_name" {
  description = "Navnet på den Cilium egress gateway applikationen er tilknyttet"
  type        = string
}

variable "labels" {
  description = "Ekstra labels til ressourcerne"
  type        = map(string)
  default     = {}
}

variable "annotations" {
  description = "Ekstra annotations til ressourcerne"
  type        = map(string)
  default     = {}
}

variable "node_selector" {
  description = "Node selector for pod scheduling"
  type        = map(string)
  default     = {}
}

variable "volumes" {
  description = "Liste af PVC volumes der skal mountes i containeren"
  type = list(object({
    name       = string
    claim_name = string
    mount_path = string
    read_only  = optional(bool, false)
  }))
  default = []
}
