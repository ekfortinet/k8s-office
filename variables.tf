variable "kubeconfig_path" {
  description = "Sti til kubeconfig-fil"
  type        = string
  default     = "~/.kube/config"
}

variable "kube_context" {
  description = "Kubernetes context at anvende"
  type        = string
}

variable "cluster_name" {
  description = "Navn på Kubernetes-clusteret"
  type        = string
  default     = "prod-cluster"
}

variable "calico_version" {
  description = "Calico Helm chart version"
  type        = string
  default     = "3.27.0"
}

variable "bgp_peer_ip" {
  description = "IP på upstream BGP router/peer"
  type        = string
}

variable "bgp_as_number" {
  description = "BGP AS-nummer for clusteret"
  type        = number
  default     = 64512
}

variable "bgp_peer_as_number" {
  description = "BGP AS-nummer på upstream peer"
  type        = number
  default     = 64513
}