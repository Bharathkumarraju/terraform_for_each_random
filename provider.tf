terraform {
  required_version = "~> 1.1"

  required_providers {

    vault   = {
      source  = "hashicorp/vault"
      version = "3.7.0"
    }
  }
}

provider "vault" {
  skip_tls_verify = true
}