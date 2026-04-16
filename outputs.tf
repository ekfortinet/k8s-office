output "application_ips" {
  description = "Oversigt over alle applikationer og deres eksterne IP'er"
  value = {
    for name, app in local.applications : name => {
      external_ip = app.external_ip
      namespace   = app.namespace
      port        = app.port
      description = app.description
    }
  }
}

output "services" {
  description = "Kubernetes Service navne og IP'er"
  value = {
    for name, svc in kubernetes_service.app_services :
    name => svc.status[0].load_balancer[0].ingress[0].ip
  }
}