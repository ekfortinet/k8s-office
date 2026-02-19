# K8s Office - Guide

Denne guide beskriver hvordan du tilføjer/fjerner applikationer og egress gateways i K8s-klyngen.

**Alt styres via `terraform.tfvars`** — filen er single source of truth.

---

## Forudsætninger

- Self-hosted GitHub Actions runner kører på `k8s-master` (10.200.0.11)
- Terraform er installeret på `k8s-master`
- `terraform.tfvars` eksisterer (kopiér fra `terraform.tfvars.example`)

---

## Tilføj en Applikation

1. Åbn `terraform.tfvars`
2. Tilføj en ny entry i `applications` blokken:

```hcl
applications = {
  # ... eksisterende apps ...

  min-app = {
    namespace     = "min-app"
    helm_repo     = "https://charts.example.com"
    helm_chart    = "min-app-chart"
    chart_version = "1.0.0"
    set_values = [
      { name = "service.type", value = "ClusterIP" },
      { name = "replicaCount", value = "2" },
    ]
  }
}
```

3. Commit og push til `main`:

```bash
git add terraform.tfvars
git commit -m "Add min-app"
git push origin main
```

4. GitHub Actions kører automatisk `terraform apply`

---

## Fjern en Applikation

1. Slet applikationens entry fra `applications` i `terraform.tfvars`
2. Commit og push — Terraform fjerner automatisk namespace, Helm release, og tilhørende egress policy

---

## Tilføj en Egress Gateway

1. Tilføj en ny entry i `egress_gateways` blokken i `terraform.tfvars`:

```hcl
egress_gateways = {
  # Key = namespace der skal bruge egress gateway
  min-app = {
    egress_node_name  = "k8s-slave1"    # Node der fungerer som gateway
    egress_node_ip    = "10.200.0.9"    # IP på gateway-noden
    destination_cidrs = ["0.0.0.0/0"]   # Hvilke destinations der routes via gateway
  }
}
```

2. Commit og push til `main`

### Tilgængelige egress noder

| Node | IP |
|------|------|
| k8s-slave1 | 10.200.0.9 |
| k8s-slave2 | 10.200.0.10 |

---

## Fjern en Egress Gateway

1. Slet namespacets entry fra `egress_gateways` i `terraform.tfvars`
2. Commit og push

---

## Filstruktur

| Fil | Beskrivelse |
|-----|-------------|
| `providers.tf` | Kubernetes og Helm provider konfiguration |
| `variables.tf` | Variable-definitioner |
| `terraform.tfvars` | **Source of truth** — dine apps og egress gateways |
| `terraform.tfvars.example` | Eksempel med kommentarer |
| `main.tf` | Namespace-oprettelse |
| `cilium.tf` | Cilium CNI installation |
| `applications.tf` | Dynamisk app-deployment |
| `egress.tf` | Cilium egress gateway policies |
| `outputs.tf` | Terraform outputs |
| `HISTORY.md` | Ændringshistorik |

---

## Fejlfinding

```bash
# Tjek Terraform state
terraform state list

# Se status på en specifik app
terraform state show 'helm_release.applications["min-app"]'

# Manuelt plan uden apply
terraform plan

# Tjek Cilium status
kubectl -n kube-system get pods -l app.kubernetes.io/name=cilium

# Tjek egress policies
kubectl get ciliumegressgatewaypolicies
```
