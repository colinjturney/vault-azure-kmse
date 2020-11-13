resource "azurerm_resource_group" "rg" {
  name     = var.arg_name
  location = var.arg_location

  tags = {
      creator = var.tag_creator
  }

}
