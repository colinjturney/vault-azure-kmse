module "tf-az-rg" {
  source = "../modules/tf-az-rg"

  arg_name      = var.arg_name
  arg_location  = var.arg_location

  tag_creator   = var.tag_creator
}


module "tf-az-vault-infra" {
  source = "../modules/tf-az-vault-infra"

  key_collection  = module.tf-az-key-vault.key_collection
  client_id       = module.tf-az-key-vault.client_id
  client_secret   = module.tf-az-key-vault.client_secret
  tenant_id       = module.tf-az-key-vault.tenant_id

  vnet_address_space      = var.infra_vnet_address_space
  subnet_address_prefixes = var.infra_subnet_address_prefixes
  ssh_allow_prefix        = var.infra_ssh_allow_prefix

  arg_name      = module.tf-az-rg.arg_name
  arg_location  = module.tf-az-rg.arg_location
  arg_id        = module.tf-az-rg.arg_id

  name_prefix   = var.name_prefix

  tag_creator = var.tag_creator
  
  depends_on = [module.tf-az-rg]

}

module "tf-az-key-vault" {
  source = "../modules/tf-az-key-vault"
  
  arg_name      = module.tf-az-rg.arg_name
  arg_location  = module.tf-az-rg.arg_location
  arg_id        = module.tf-az-rg.arg_id

  kv_name_prefix  = var.name_prefix

  depends_on = [module.tf-az-rg]
}