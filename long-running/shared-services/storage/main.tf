terraform {
  backend "azurerm" {}
}

data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "itds_rg" {
  name = "${var.env_prefix_hypon}-rg"
  location = "${var.env_location}"
  provisioner "local-exec" {
    command = "az extension add --name storage-preview && az storage account create --name ${var.shsrv_sa} --resource-group ${azurerm_resource_group.itds_rg.name} --kind StorageV2 --hierarchical-namespace --https-only true --assign-identity --sku Standard_LRS"
  }
}