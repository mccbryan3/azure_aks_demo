data "azurerm_resource_group" "resource-group" {
  name = var.resource_group_name
}

data "azurerm_client_config" "current" {
}