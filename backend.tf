# -----------------------------------------------------------------------------
# Terraform Backend
# 
# Terraform state gemmes lokalt som standard.
# Skift til en remote backend (f.eks. S3, GCS, Consul) når du er klar.
#
# Eksempel med S3-kompatibel backend:
# terraform {
#   backend "s3" {
#     bucket         = "k8s-office-tfstate"
#     key            = "terraform.tfstate"
#     region         = "eu-west-1"
#     encrypt        = true
#     dynamodb_table = "k8s-office-tfstate-lock"
#   }
# }
# -----------------------------------------------------------------------------

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
