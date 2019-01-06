terraform {
  backend "azurerm" {}
}
data "azurerm_subscription" "current" {}


resource "azurerm_role_definition" "itds-dta-eng-rl" {
  name        = "${var.env_prefix}-dta-eng-rl"
  scope       = "${data.azurerm_subscription.current.id}"
  description = "ITDS Data Engineer role"

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    "${data.azurerm_subscription.current.id}"
  ]
}


resource "azurerm_resource_group" "itds_shrd_srv_rdis_rg" {
  name     = "${var.itds_shrd_srv_rdis_rg}"
  location = "${var.env_location}"
}

resource "azurerm_resource_group" "itds_shrd_srv_mysql_rg" {
  name     = "${var.itds_shrd_srv_mysql_rg}"
  location = "${var.env_location}"
}

