data "azurerm_client_config" "current" {}

# Create disk encryption set

resource "azurerm_disk_encryption_set" "des" {
  name                = "${var.name_prefix}-des"
  resource_group_name = var.arg_name
  location            = var.arg_location
  key_vault_key_id    = var.kvk_id

  identity {
    type = "SystemAssigned"
  }

  tags = {
    creator = var.tag_creator
  }
}

resource "azurerm_key_vault_access_policy" "des-disk" {
  key_vault_id = var.kv_id

  tenant_id = azurerm_disk_encryption_set.des.identity.0.tenant_id
  object_id = azurerm_disk_encryption_set.des.identity.0.principal_id

  key_permissions = [
    "decrypt",
    "encrypt",
    "get",
    "wrapKey",
    "unwrapKey"
  ]
}

# Create VM resource

resource "azurerm_public_ip" "publicip-example" {
    name    = "${var.name_prefix}-publicip-example"
    
    location            = var.arg_location
    resource_group_name = var.arg_name

    allocation_method            = "Dynamic"

    tags = {
        creator = var.tag_creator
    }
}

resource "azurerm_network_interface" "nic-example" {
    name                        = "${var.name_prefix}-nic-example"

    location                    = var.arg_location
    resource_group_name         = var.arg_name

    ip_configuration {
        name                          = "${var.name_prefix}-nic-config-example"
        subnet_id                     = var.subnet_id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.publicip-example.id
    }

    tags = {
        creator = var.tag_creator
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "nic-sg-ass-example" {
    network_interface_id      = azurerm_network_interface.nic-example.id
    network_security_group_id = var.nsg_id
}

resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group_name = var.arg_name
    }

    byte_length = 8
}

resource "azurerm_storage_account" "sa" {
    name                        = "diag${random_id.randomId.hex}"
    
    resource_group_name         = var.arg_name
    location                    = var.arg_location
    
    account_replication_type    = "LRS"
    account_tier                = "Standard"

    tags = {
        creator = var.tag_creator
    }
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "azurerm_linux_virtual_machine" "vm" {
    name                  = "${var.name_prefix}-vm-example"

    location              = var.arg_location
    resource_group_name   = var.arg_name
    
    network_interface_ids = [azurerm_network_interface.nic-example.id]
    size                  = "Standard_B1ls"

    os_disk {
        name                    = "${var.name_prefix}-vm-disk-example"
        caching                 = "ReadWrite"
        storage_account_type    = "Premium_LRS"
        disk_encryption_set_id  = azurerm_disk_encryption_set.des.id
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    computer_name  = "example"
    admin_username = "azureuser"
    disable_password_authentication = true

    admin_ssh_key {
        username       = "azureuser"
        public_key     = tls_private_key.ssh.public_key_openssh
    }

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.sa.primary_blob_endpoint
    }

    tags = {
        creator = var.tag_creator
    }
}