# 🏗️ Infrastructure Guide – k8s-office

> **VIGTIG:** Denne fil er den primære reference for al infrastrukturarbejde i dette repository.
> AI-assistenter **SKAL** læse denne fil inden de foretager ændringer.

---

## 📋 Oversigt

Dette repository styrer en on-premise Kubernetes-klynge via **Terraform** og **GitHub Actions**.
Al infrastruktur er defineret som kode (IaC) og deployes automatisk via CI/CD.

**Alt er variabel-drevet:** Namespaces, egress gateways og applikationer defineres i
`terraform.tfvars`. Tilføj/fjern en entry → Terraform opretter/sletter Kubernetes-ressourcen.

---

## 🖥️ Klynge-topologi

| Node        | Rolle  | Hostname      | IP          | Beskrivelse                          |
|-------------|--------|---------------|-------------|--------------------------------------|
| k8s-master  | Master | k8s-master    | 10.200.0.11 | Control plane + GitHub Actions runner |
| k8s-slave1  | Worker | k8s-slave1    | 10.200.0.9  | Worker node 1                        |
| k8s-slave2  | Worker | k8s-slave2    | –           | Worker node 2                        |

- **Kubernetes distribution:** Kubeadm (standard)
- **Container runtime:** containerd
- **CNI:** Cilium (med EgressGateway-funktionalitet aktiveret)
- **Egress:** CiliumEgressGatewayPolicy

### Cilium Krav
Cilium skal have egress gateway feature aktiveret:
```bash
helm upgrade cilium cilium/cilium \
  --namespace kube-system \
  --set egressGateway.enabled=true \
  --set bpf.masquerade=true
```

---

## 📁 Repository-struktur

```
k8s-office/
├── INFRASTRUCTURE_GUIDE.md              ← DENNE FIL – Læs altid først!
├── .github/
│   └── workflows/
│       ├── terraform-plan.yml           ← Kører terraform plan på PRs
│       └── terraform-apply.yml          ← Kører terraform apply ved merge til main
├── provider.tf                          ← Kubernetes, Helm & kubectl providers
├── versions.tf                          ← Terraform version constraints
├── variables.tf                         ← ⭐ ALLE VARIABLER (apps, gateways, namespaces)
├── backend.tf                           ← Terraform state backend
├── terraform.tfvars.example             ← Eksempel med n8n + slave1 egress
├── namespaces.tf                        ← for_each → namespaces
├── egress-gateways.tf                   ← for_each → Cilium egress gateways
├── applications.tf                      ← for_each → apps + validering
├── outputs.tf                           ← Oversigt over oprettede ressourcer
└── modules/
    ├── egress-gateway/                  ← Genbrugeligt modul: CiliumEgressGatewayPolicy
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── application/                     ← Genbrugeligt modul: Deployment + Service
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

---

## ⭐ Variabel-drevet arkitektur

### Princip
```
terraform.tfvars → variables.tf → for_each → Kubernetes ressourcer
```

Tilføj en entry → den oprettes. Fjern en entry → den slettes. Ingen manuel kubectl.

---

## 🌐 Egress Gateway – Cilium

### Sådan virker det
Cilium `EgressGatewayPolicy` matcher pods baseret på labels og router deres **udgående trafik**
via en bestemt node med en specifik IP-adresse.

```
Pod → Cilium → EgressGatewayPolicy → Gateway Node (slave1: 10.200.0.9) → Internet
```

### Sammenhæng mellem app og gateway
```
applications.n8n.egress_gateway_name = "slave1"
    ↓
Pod labels: "egress-gateway/name" = "slave1"
    ↓
CiliumEgressGatewayPolicy (egress-slave1):
  podSelector.matchLabels: "egress-gateway/name" = "slave1"
  egressGateway.nodeSelector: kubernetes.io/hostname = k8s-slave1
  egressGateway.egressIP: 10.200.0.9
```

### Ressourcer oprettet per gateway
| Ressource                    | Scope   | Formål                                    |
|------------------------------|---------|-------------------------------------------|
| CiliumEgressGatewayPolicy    | Cluster | Matcher pods → router via gateway node    |

### Ressourcer oprettet per app
| Ressource   | Scope     | Formål                                            |
|-------------|-----------|---------------------------------------------------|
| Deployment  | Namespace | Kører applikationens pods                          |
| Service     | Namespace | ClusterIP service for intern kommunikation         |

---

## 📝 Variable Reference

### `egress_gateways` (map)
```hcl
egress_gateways = {
  slave1 = {                                          # ← Gateway-navn (bruges af apps)
    node_labels = {
      "kubernetes.io/hostname" = "k8s-slave1"         # ← Hvilken node der er gateway
    }
    egress_ip         = "10.200.0.9"                  # ← IP for udgående trafik
    destination_cidrs = ["0.0.0.0/0"]                 # ← Default: al trafik
  }
}
```

### `applications` (map)
```hcl
applications = {
  n8n = {                                             # ← App-navn
    namespace           = "apps"
    egress_gateway_name = "slave1"                    # ← SKAL matche gateway-nøgle!
    image               = "n8nio/n8n:latest"
    replicas            = 1
    container_port      = 5678
    service_port        = 5678
    env_vars = {
      N8N_PORT         = "5678"
      GENERIC_TIMEZONE = "Europe/Copenhagen"
    }
    resource_limits = {
      cpu    = "1000m"
      memory = "1024Mi"
    }
    volumes = [                                       # ← Persistent data
      {
        name       = "n8n-data"
        claim_name = "n8n-data-pvc"
        mount_path = "/home/node/.n8n"
      }
    ]
  }
}
```

### `namespaces` (map)
```hcl
namespaces = {
  apps = {}
}
```

---

## 📦 Nuværende Applikationer

| App   | Namespace | Image              | Port | Egress Gateway | Gateway Node | Egress IP   |
|-------|-----------|--------------------|------|----------------|--------------|-------------|
| n8n   | apps      | n8nio/n8n:latest   | 5678 | slave1         | k8s-slave1   | 10.200.0.9  |

---

## 🔧 Daglige operationer

### Tilføj en ny app
1. Tilføj gateway i `egress_gateways` (eller genbrug eksisterende)
2. Tilføj app i `applications` med `egress_gateway_name` der matcher
3. Opret evt. PVC manuelt hvis appen kræver persistens
4. Kør `terraform plan` → review → merge PR → auto-apply

### Fjern en app
1. Slet app-entryen fra `applications`
2. Kør `terraform plan` → review → merge PR → auto-apply
3. Deployment + Service slettes automatisk

### Del en gateway mellem apps
```hcl
applications = {
  app-a = {
    egress_gateway_name = "slave1"    # ← Begge bruger
    ...
  }
  app-b = {
    egress_gateway_name = "slave1"    # ← samme gateway
    ...
  }
}
```

### Tilføj en ny egress gateway (f.eks. slave2)
```hcl
egress_gateways = {
  slave1 = { ... }
  slave2 = {
    node_labels = {
      "kubernetes.io/hostname" = "k8s-slave2"
    }
    egress_ip         = "<slave2-ip>"
    destination_cidrs = ["0.0.0.0/0"]
  }
}
```

---

## 🚀 CI/CD Pipeline (GitHub Actions)

### Runner: Self-hosted på k8s-master
GitHub Actions bruger en **self-hosted runner** installeret på `k8s-master`.
Runneren har direkte adgang til `~/.kube/config` og kan nå Kubernetes API'et
på `https://10.200.0.11:6443`.

### Workflow: Pull Request
1. Branch oprettes med ændringer
2. PR mod `main` → self-hosted runner kører `terraform plan`
3. Plan-output vises som kommentar på PR
4. Review + approve

### Workflow: Merge til Main
1. PR merges → self-hosted runner kører `terraform apply`
2. Ændringer deployes til klyngen

---

## ⚠️ Regler for AI-assistenter

1. **Læs ALTID denne fil først** inden du foretager infrastruktuændringer
2. **Brug ALTID Terraform variabler** – tilføj apps/gateways i `terraform.tfvars`
3. **Opret ALDRIG en app uden `egress_gateway_name`** – Terraform validering fejler
4. **Opret ALDRIG ressourcer manuelt med `kubectl`** – alt styres via Terraform
5. **Hold dig til mappestrukturen** beskrevet ovenfor
6. **Push ALDRIG ændringer** medmindre brugeren eksplicit beder om det
7. **Test med `terraform plan`** inden du foreslår apply
8. **Opdater denne guide** ved nye patterns, moduler eller konventioner
9. **Tilføj apps i `var.applications`** – opret ALDRIG separate .tf filer per app
10. **Egress gateways bruger Cilium** – IKKE Istio, IKKE NetworkPolicy

---

## 📝 Changelog

| Dato       | Ændring                                                        | Af  |
|------------|----------------------------------------------------------------|-----|
| 2026-02-19 | Initial setup: klynge, egress gw modul, CI/CD                 | AI  |
| 2026-02-19 | Refactor til variabel-drevet: apps, gateways, namespaces       | AI  |
| 2026-02-19 | Skiftet fra Istio til Cilium EgressGatewayPolicy               | AI  |
| 2026-02-19 | Tilføjet n8n som eksempel-app med slave1 egress (10.200.0.9)   | AI  |
| 2026-02-19 | Tilføjet volume/PVC support til application modul              | AI  |
| 2026-02-19 | Opdateret klynge-topologi med IP-adresser                      | AI  |
| 2026-02-19 | Skiftet til self-hosted runner (k8s-master: 10.200.0.11)       | AI  |

---
