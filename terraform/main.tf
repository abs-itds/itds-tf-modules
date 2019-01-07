terraform {
  backend "azurerm" {}
}
data "azurerm_subscription" "current" {}

data "azurerm_virtual_network" "itds_vnet" {
  name                = "${var.vnet_name}"
  resource_group_name = "${var.vnet_rg_name}"
}

resource "azurerm_resource_group" "itds_tf_rg" {
  name     = "${var.env_prefix_hypon}-tf-rg"
  location = "${var.env_location}"
}

resource "azurerm_subnet" "itds_tf_snet" {
  name                 = "${var.env_prefix_hypon}-tf-snet"
  resource_group_name  = "${data.azurerm_virtual_network.itds_vnet.resource_group_name}"
  virtual_network_name = "${data.azurerm_virtual_network.itds_vnet.name}"
  address_prefix       = "${var.tf_snet_address_prefix}"
  service_endpoints    = ["Microsoft.Storage"]
}

resource "azurerm_storage_account" "itds_tf_sa" {
  name                = "${var.tf_sa_name}"
  resource_group_name = "${azurerm_resource_group.itds_tf_rg.name}"
  location                 = "${var.env_location}"
  account_tier             = "Standard"
  account_replication_type = "GRS"
 /* network_rules {
    virtual_network_subnet_ids = ["${azurerm_subnet.itds_tf_snet.id}"]
  }*/
  tags {
    purpose = "terraform-state-backend"
  }
}

resource "azurerm_storage_container" "itds_tf_sa_sc" {
  name                  = "${var.env_prefix_hypon}-tf-sa-sc"
  resource_group_name   = "${azurerm_resource_group.itds_tf_rg.name}"
  storage_account_name  = "${azurerm_storage_account.itds_tf_sa.name}"
  container_access_type = "private"
}


