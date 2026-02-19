# -----------------------------------------------------------------------------
# Kubernetes Provider
# Bruger kubeconfig injiceret via KUBE_CONFIG_DATA GitHub secret
# -----------------------------------------------------------------------------
provider "kubernetes" {
  config_path    = var.kubeconfig_path
  config_context = var.kubeconfig_context != "" ? var.kubeconfig_context : null
}

# -----------------------------------------------------------------------------
# Helm Provider
# -----------------------------------------------------------------------------
provider "helm" {
  kubernetes {
    config_path    = var.kubeconfig_path
    config_context = var.kubeconfig_context != "" ? var.kubeconfig_context : null
  }
}

# -----------------------------------------------------------------------------
# Kubectl Provider
# Bruges til Cilium CRDs (CiliumEgressGatewayPolicy, etc.)
# -----------------------------------------------------------------------------
provider "kubectl" {
  config_path    = var.kubeconfig_path
  config_context = var.kubeconfig_context != "" ? var.kubeconfig_context : null
}
