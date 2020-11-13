variable "arg_name" {
    type = string
    description = "Azure Resource Group name"
}

variable "arg_location" {
    type = string
    description = "Azure Resource Group Location"
}

variable "kv_name_prefix" {
    type = string
    description = "Prefix to apply to the name of the Azure Key Vault"
}

variable "infra_vnet_address_space" {
    type = list
}

variable "infra_subnet_address_prefixes" {
    type = list
}

variable "infra_ssh_allow_prefix" {
    type = string
}

variable "tag_creator" {
    type = string
}