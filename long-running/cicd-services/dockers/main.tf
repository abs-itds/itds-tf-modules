terraform {
  backend "azurerm" {}
}

data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "itds_shrd_srv_acr_rg" {
  name = "${var.env_prefix_hypon}-shrd-srv-jnkns-rg"
  location = "${var.env_location}"
}

resource "azurerm_storage_account" "itds_shrd_srv_acr_sa" {
  name                = "${var.env_prefix_hypon}-shrd-srv-jnkns-sa"
  resource_group_name = "${azurerm_resource_group.itds_shrd_srv_acr_rg.name}"
  location                 = "${var.env_location}"
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_container_registry" "itds_shrd_srv_acr" {
  name                   = "${var.env_prefix_hypon}-shrd-srv-acr"
  resource_group_name    = "${azurerm_resource_group.itds_shrd_srv_acr_rg.name}"
  location               = "${azurerm_resource_group.itds_shrd_srv_acr_rg.location}"
  sku                    = "Standard"
  storage_account_id = "${azurerm_storage_account.itds_shrd_srv_acr_sa.id}"
  admin_enabled          = true
  georeplication_locations = ["${var.env_location}"]
}

