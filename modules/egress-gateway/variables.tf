# -----------------------------------------------------------------------------
# Cilium Egress Gateway Module – Variables
# -----------------------------------------------------------------------------

variable "name" {
  description = "Unikt navn for denne egress gateway"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.name))
    error_message = "Navn må kun indeholde lowercase bogstaver, tal og bindestreger."
  }
}

variable "node_labels" {
  description = "Labels til at vælge hvilken node der fungerer som egress gateway"
  type        = map(string)
}

variable "egress_ip" {
  description = "IP-adressen som udgående trafik skal bruge (gateway-nodens IP)"
  type        = string

  validation {
    condition     = can(regex("^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}$", var.egress_ip))
    error_message = "egress_ip skal være en valid IPv4-adresse."
  }
}

variable "destination_cidrs" {
  description = "Destination CIDRs som skal routes via denne egress gateway"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "pod_selector_labels" {
  description = "Labels der bruges til at matche pods til denne egress gateway"
  type        = map(string)
  default     = {}
}

variable "labels" {
  description = "Ekstra labels til ressourcerne"
  type        = map(string)
  default     = {}
}
