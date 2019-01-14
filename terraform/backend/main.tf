terraform {
  backend "azurerm" {}
}

data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "itds_tf_rg" {
  name     = "${var.env_prefix_hypon}-tf-rg"
  location = "${var.env_location}"
}

resource "azurerm_storage_account" "itds_tf_sa" {
  name                = "${var.tf_sa_name}"
  resource_group_name = "${azurerm_resource_group.itds_tf_rg.name}"
  location                 = "${var.env_location}"
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_storage_container" "itds_tf_sa_sc" {
  name                  = "${var.env_prefix_hypon}-tf-sa-sc"
  resource_group_name   = "${azurerm_resource_group.itds_tf_rg.name}"
  storage_account_name  = "${azurerm_storage_account.itds_tf_sa.name}"
  container_access_type = "private"
}


