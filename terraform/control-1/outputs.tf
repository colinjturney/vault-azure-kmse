output "tls_private_key" { 
    value = module.tf-az-vault-infra.tls_private_key 
}

output "vm_public_ip" {
    value = module.tf-az-vault-infra.vm_public_ip
}

output "subnet_id" {
    value = module.tf-az-vault-infra.subnet_id
}

output "nsg_id" {
    value = module.tf-az-vault-infra.nsg_id
}

output "arg_location" {
    value = module.tf-az-rg.arg_location
}

output "arg_name" {
    value = module.tf-az-rg.arg_name
}

output "key_vault_id" {
    value = module.tf-az-key-vault.key_vault_id
}
