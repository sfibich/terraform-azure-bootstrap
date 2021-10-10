resource "azurerm_resource_group" "rg" {
  name     = "${var.rg_prefix}-simple-test"
  location = "eastus2"
  tags = merge(var.tags,var.env_tags)
}




