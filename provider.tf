# -----------------------------------------------------------------------------
# Kubernetes Provider
# Bruger kubeconfig til at forbinde til klyngen (k8s-master)
# -----------------------------------------------------------------------------
provider "kubernetes" {
  config_path    = var.kubeconfig_path
  config_context = var.kubeconfig_context
}

# -----------------------------------------------------------------------------
# Helm Provider
# Bruges til at installere Helm charts (f.eks. Cilium, applikationer)
# -----------------------------------------------------------------------------
provider "helm" {
  kubernetes {
    config_path    = var.kubeconfig_path
    config_context = var.kubeconfig_context
  }
}

# -----------------------------------------------------------------------------
# Kubectl Provider
# Bruges til Cilium CRDs (CiliumEgressGatewayPolicy, etc.)
# -----------------------------------------------------------------------------
provider "kubectl" {
  config_path    = var.kubeconfig_path
  config_context = var.kubeconfig_context
}
