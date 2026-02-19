# =============================================================================
# Cilium CNI Installation via Helm
# =============================================================================

resource "helm_release" "cilium" {
  name       = "cilium"
  namespace  = "kube-system"
  repository = "https://helm.cilium.io/"
  chart      = "cilium"
  version    = "1.16.5"

  # Aktiver egress gateway support
  set {
    name  = "egressGateway.enabled"
    value = "true"
  }

  # Kræves for egress gateway
  set {
    name  = "bpf.masquerade"
    value = "true"
  }

  # Aktiver Kubernetes host-scope IPAM
  set {
    name  = "ipam.mode"
    value = "kubernetes"
  }

  # Operator replicas
  set {
    name  = "operator.replicas"
    value = "1"
  }

  # Vent på at Cilium er klar
  wait    = true
  timeout = 600
}
