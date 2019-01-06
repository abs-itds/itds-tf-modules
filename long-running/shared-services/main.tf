terraform {
  backend "azurerm" {}
}
data "azurerm_subscription" "current" {}





resource "azurerm_resource_group" "itds_shrd_srv_rdis_rg" {
  name     = "${var.itds_shrd_srv_rdis_rg}"
  location = "${var.env_location}"
}


resource "azurerm_resource_group" "itds_shrd_srv_mysql_rg" {
  name     = "${var.itds_shrd_srv_mysql_rg}"
  location = "${var.env_location}"
}
