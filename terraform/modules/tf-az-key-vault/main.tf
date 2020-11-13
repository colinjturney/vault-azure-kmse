resource "random_id" "app_rg_name" {
  byte_length = 3
}

resource "random_id" "keyvault_name" {
  byte_length = 3
}

data "azurerm_client_config" "current" {}

resource "azuread_application" "key_vault_app" {
    name                       = "app-${random_id.app_rg_name.hex}"
    homepage                   = "http://homepage${random_id.app_rg_name.b64_url}"
    identifier_uris            = ["http://uri${random_id.app_rg_name.b64_url}"]
    reply_urls                 = ["http://replyurl${random_id.app_rg_name.b64_url}"]
    available_to_other_tenants = false
    oauth2_allow_implicit_flow = true
}

resource "azuread_service_principal" "key_vault_sp" {
    application_id               = azuread_application.key_vault_app.application_id
    app_role_assignment_required = false
}

resource "random_password" "password" {
  length           = 24
  special          = true
  override_special = "%@"
}

resource "azuread_service_principal_password" "key_vault_sp_pwd" {
    service_principal_id = azuread_service_principal.key_vault_sp.id
    value                = random_password.password.result
    end_date             = "2099-01-01T01:02:03Z"
}

resource "azurerm_key_vault" "key_vault_kv" {
  name                = "${var.kv_name_prefix}-${random_id.keyvault_name.hex}"
  location            = var.arg_location
  resource_group_name = var.arg_name
  sku_name            = "premium"
  soft_delete_enabled = true
  tenant_id           = data.azurerm_client_config.current.tenant_id

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    key_permissions = [
      "backup",
      "create",
      "decrypt",
      "delete",
      "encrypt",
      "get",
      "import",
      "list",
      "purge",
      "recover",
      "restore",
      "sign",
      "unwrapKey",
      "update",
      "verify",
      "wrapKey"
    ]
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azuread_service_principal.key_vault_sp.object_id
    key_permissions = [
      "create",
      "delete",
      "get",
      "import",
      "update"
    ]
  }
}
