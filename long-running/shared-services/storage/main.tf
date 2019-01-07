terraform {
  backend "azurerm" {}
}

data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "itds_subs_rg" {
  name = "${var.env_prefix_hypon}-rg"
  location = "${var.env_location}"
}

resource "azurerm_storage_account" "itds_shsrv_sa" {
  name = "${var.shsrv_sa}"
  resource_group_name = "${azurerm_resource_group.itds_subs_rg.name}"
  location = "${azurerm_resource_group.itds_subs_rg.location}"
  account_tier = "Premium"
  account_replication_type = "LRS"
  account_kind = "StorageV2"
  access_tier = "Hot"
  enable_https_traffic_only = true
  #isHnsEnabled = true
  #TODO
  #network_rules {
  #  virtual_network_subnet_ids = [
  #    "${azurerm_subnet.itds_tf_snet.id}"]
  #}
  identity {
    type = "SystemAssigned"
  }

}

