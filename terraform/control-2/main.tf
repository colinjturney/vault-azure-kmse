data "terraform_remote_state" "control-1" {
  backend = "local"

  config = {
    path = "${path.cwd}/../control-1/terraform.tfstate"
  }
}

module "tf-az-usage-example" {
  source = "../modules/tf-az-usage-example"

  arg_name      = data.terraform_remote_state.control-1.outputs.arg_name
  arg_location  = data.terraform_remote_state.control-1.outputs.arg_location

  kv_id         = data.terraform_remote_state.control-1.outputs.key_vault_id
  kvk_id        = var.example_kvk_id

  subnet_id     = data.terraform_remote_state.control-1.outputs.subnet_id
  nsg_id        = data.terraform_remote_state.control-1.outputs.nsg_id

  name_prefix   = var.name_prefix

  tag_creator   = var.tag_creator
}


