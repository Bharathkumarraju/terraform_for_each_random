
locals {
  test_microservices = yamldecode(file("secrets.yaml"))["microservices"]
  number_of_secrets = [for k, v in local.test_microservices : v.inject_secrets if contains(keys(v), "create_tyksecrets")]
}


resource "random_password" "tyk-secrets" {
  for_each = toset(local.number_of_secrets)

  length  = 32
  special = false
}


resource "vault_generic_secret" "tyk-vault" {
  for_each  = { for k, v in local.test_microservices : k => v.inject_secrets if contains(keys(v), "create_tyksecrets") }
  path      = format("secret/dev/${each.key}")
  data_json = <<EOT
  {
    "redis_password": "${random_password.tyk-secrets[each.value.redis_password].result}",
    "mongodb_password": "${random_password.tyk-secrets[each.value.mongodb_password].result}",
    "admin_password": "${random_password.tyk-secrets[each.value.admin_password].result}",
  }
  EOT

  lifecycle {
    ignore_changes = [
      data_json
    ]
  }
}
