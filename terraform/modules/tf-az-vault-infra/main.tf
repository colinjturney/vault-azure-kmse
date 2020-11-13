resource "azurerm_virtual_network" "virtual_network" {
    name = "azure-kmse-testing-network"
    
    location            = var.arg_location
    resource_group_name = var.arg_name
    
    address_space = var.vnet_address_space
    
    tags = {
        creator = var.tag_creator
    }
}

resource "azurerm_subnet" "subnet" {
    name = "azure-kmse-testing-subnet"
    
    resource_group_name     = var.arg_name

    address_prefixes        = var.subnet_address_prefixes
    virtual_network_name    = azurerm_virtual_network.virtual_network.name    
}

resource "azurerm_public_ip" "publicip" {
    name                         = "azure-kmse-testing-publicip"
    
    location            = var.arg_location
    resource_group_name = var.arg_name

    allocation_method            = "Dynamic"

    tags = {
        creator = var.tag_creator
    }
}

resource "azurerm_network_security_group" "nsg" {
    name                = "azure-kmse-testing-nsg"
   
    location            = var.arg_location
    resource_group_name = var.arg_name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = var.ssh_allow_prefix
        destination_address_prefix = "*"
    }

    tags = {
        creator = var.tag_creator
    }
}

resource "azurerm_network_interface" "nic" {
    name                        = "azure-kmse-testing-nic"

    location                    = var.arg_location
    resource_group_name         = var.arg_name

    ip_configuration {
        name                          = "azure-kmse-testing-nic-config"
        subnet_id                     = azurerm_subnet.subnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.publicip.id
    }

    tags = {
        creator = var.tag_creator
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "nic-sg-ass" {
    network_interface_id      = azurerm_network_interface.nic.id
    network_security_group_id = azurerm_network_security_group.nsg.id
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
    name                  = "azure-kmse-testing-vm"

    location              = var.arg_location
    resource_group_name   = var.arg_name
    
    network_interface_ids = [azurerm_network_interface.nic.id]
    size                  = "Standard_B2s"

    os_disk {
        name                    = "myOsDisk"
        caching                 = "ReadWrite"
        storage_account_type    = "Premium_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    computer_name  = "vault"
    admin_username = "azureuser"
    disable_password_authentication = true

    custom_data = base64encode(data.template_file.linux-vm-cloud-init.rendered)

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

# Data template Bash bootstrapping file
data "template_file" "linux-vm-cloud-init" {
  template = file("${path.module}/azure-user-data.sh")
  vars = {
    key_collection = var.key_collection
    client_id = var.client_id
    client_secret = var.client_secret
    tenant_id = var.tenant_id   
  }
}

resource "local_file" "key" {
    content = tls_private_key.ssh.private_key_pem 
    filename = "${path.root}/vault-ssh.pem"
    file_permission = "0400"
}