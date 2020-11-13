output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "client_id" {
  value = azuread_application.key_vault_app.application_id
}

output "client_secret" {
  value = azuread_service_principal_password.key_vault_sp_pwd.value
}

output "key_collection" {
  value = "${var.kv_name_prefix}-${random_id.keyvault_name.hex}"
}