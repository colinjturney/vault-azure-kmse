output "tls_private_key" { 
    value = module.tf-az-vault-infra.tls_private_key 
}

output "vm_public_ip" {
    value = module.tf-az-vault-infra.vm_public_ip
}