# app_ips.tf
# ============================================================
# SOURCE OF TRUTH: Applikationer og deres eksterne IP-adresser
# Tilføj en ny entry her for at give en app en ekstern IP.
# ============================================================

locals {
  applications = {
    "app-frontend" = {
      external_ip  = "203.0.113.10"
      namespace    = "production"
      port         = 80
      replicas     = 2
      image        = "ghcr.io/dit-org/frontend:1.2.0"
      description  = "Frontend webapp"
    }
    "app-api" = {
      external_ip  = "203.0.113.11"
      namespace    = "production"
      port         = 8080
      image        = "ghcr.io/dit-org/api:1.2.0"
      description  = "REST API backend"
    }
    "app-db" = {
      external_ip  = "203.0.113.12"
      namespace    = "production"
      port         = 5432
      image        = "postgres:16"
      description  = "PostgreSQL database"
    }
    "app-monitoring" = {
      external_ip  = "203.0.113.13"
      namespace    = "monitoring"
      port         = 3000
      image        = "grafana/grafana:10.3.0"
      description  = "Grafana dashboard"
    }
  }

  # IP-pool CIDR der dækker alle eksterne IP'er ovenfor
  external_ip_pool_cidr = "203.0.113.0/24"
}