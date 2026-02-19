# -----------------------------------------------------------------------------
# Kubernetes Provider
#
# Når Terraform kører INDE i klyngen (self-hosted runner):
#   - Sæt kubeconfig_path = "" (tom) → bruger in-cluster service account
#
# Når Terraform kører UDENFOR klyngen (lokalt/GitHub-hosted):
#   - Sæt kubeconfig_path = "~/.kube/config" → bruger kubeconfig fil
# -----------------------------------------------------------------------------
provider "kubernetes" {
  config_path    = var.kubeconfig_path != "" ? var.kubeconfig_path : null
  config_context = var.kubeconfig_context != "" ? var.kubeconfig_context : null
}

# -----------------------------------------------------------------------------
# Helm Provider
# -----------------------------------------------------------------------------
provider "helm" {
  kubernetes {
    config_path    = var.kubeconfig_path != "" ? var.kubeconfig_path : null
    config_context = var.kubeconfig_context != "" ? var.kubeconfig_context : null
  }
}

# -----------------------------------------------------------------------------
# Kubectl Provider
# Bruges til Cilium CRDs (CiliumEgressGatewayPolicy, etc.)
# -----------------------------------------------------------------------------
provider "kubectl" {
  config_path    = var.kubeconfig_path != "" ? var.kubeconfig_path : null
  config_context = var.kubeconfig_context != "" ? var.kubeconfig_context : null
}
