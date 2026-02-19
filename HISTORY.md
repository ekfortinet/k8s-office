# K8s Office - Ændringshistorik

## 2026-02-19 — Initial Setup

### Oprettet filer
- `providers.tf` — Kubernetes og Helm provider konfiguration
- `variables.tf` — Variable-definitioner for noder, applikationer, og egress gateways
- `terraform.tfvars.example` — Eksempel-fil med kommenterede applikation- og egress-entries
- `main.tf` — Namespace-oprettelse for applikationer
- `cilium.tf` — Cilium CNI installation via Helm (v1.16.5) med egress gateway support
- `applications.tf` — Dynamisk Helm-baseret app-deployment via `for_each`
- `egress.tf` — Dynamisk CiliumEgressGatewayPolicy oprettelse via `for_each`
- `outputs.tf` — Outputs for deployede apps, egress policies, og Cilium version
- `.github/workflows/deploy.yml` — GitHub Actions workflow med self-hosted runner
- `docs/guide.md` — Guide til tilføjelse/fjernelse af apps og egress gateways
- `HISTORY.md` — Denne ændringshistorik

### Noder
| Node | IP | Rolle |
|------|------|-------|
| k8s-master | 10.200.0.11 | Control Plane + GitHub Actions Runner |
| k8s-slave1 | 10.200.0.9 | Worker |
| k8s-slave2 | 10.200.0.10 | Worker |

### Arkitektur
- **Terraform** styrer hele klyngen deklarativt
- **Cilium** bruges som CNI med egress gateway support
- **`terraform.tfvars`** er source of truth for applikationer og egress gateways
- **GitHub Actions** (self-hosted runner på k8s-master) kører automatisk `terraform apply` ved push til `main`

---

## 2026-02-19 — Tilføjet n8n Applikation

### Ændringer
- Oprettet `terraform.tfvars` med n8n som første applikation
- n8n deployes via Helm chart (`oci://8gears.container-registry.com/library/n8n` v0.25.2)
- Persistence aktiveret (5Gi)
- Egress gateway konfigureret: namespace `n8n` → `k8s-slave1` (10.200.0.9)
- Al udgående trafik fra n8n routet via k8s-slave1
