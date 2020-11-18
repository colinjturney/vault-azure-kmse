output "tls_private_key" { 
    value = tls_private_key.ssh.private_key_pem 
}

output "vm_public_ip" {
    value = azurerm_linux_virtual_machine.vm.public_ip_address
}

output "subnet_id" {
    value = azurerm_subnet.subnet.id
}

output "nsg_id" {
    value = azurerm_network_security_group.nsg.id
}