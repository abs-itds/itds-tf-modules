terraform {
  backend "azurerm" {}
}

data "azurerm_subscription" "current" {}

resource "azurerm_management_lock" "itds_rg_lk" {
  name = "${var.env_prefix_hypon}-shrd-rg-lk"
  scope = "${data.azurerm_subscription.current.id}"
  lock_level = "CanNotDelete"
  notes = "${data.azurerm_subscription.current.display_name} subscription can not be deleted"
}

resource "azurerm_resource_group" "itds_shrd_rg" {
  name = "${var.env_prefix_hypon}-shrd-rg"
  location = "${var.env_location}"
}

resource "null_resource" "itds_shrd_sa" {
  provisioner "local-exec" {
    command = "az extension add --name storage-preview && az storage account create --name ${var.shsrv_sa} --resource-group ${azurerm_resource_group.itds_shrd_rg.name} --kind StorageV2 --hierarchical-namespace --https-only true --assign-identity --sku Standard_LRS"
  }
  depends_on = [
    "azurerm_resource_group.itds_shrd_rg"
  ]
}


