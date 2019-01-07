terraform {
  backend "azurerm" {}
}

data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "itds_shsrv_srv_msql_rg" {
  name     = "${var.env_prefix_hypon}-shsrv-srv-msql-rg"
  location = "${var.env_location}"
}

resource "azurerm_mysql_server" "itds_shsrv_srv_msql" {
  name                         = "${var.env_prefix_hypon}-shsrv-srv-msql"
  location                     = "${azurerm_resource_group.itds_shsrv_srv_msql_rg.location}"
  resource_group_name          = "${azurerm_resource_group.itds_shsrv_srv_msql_rg.name}"
  administrator_login          = "${var.shsrv_srv_msql_adm_usr}"
  administrator_login_password = "${var.shsrv_srv_msql_adm_pswd}"
  version                      = "5.7"
  ssl_enforcement              = "Enabled"

  sku {
    name     = "GP_Gen5_8"
    capacity = 8
    tier     = "GeneralPurpose"
    family   = "Gen5"
  }

  storage_profile {
    storage_mb            = 2048000
    backup_retention_days = 7
    geo_redundant_backup  = "Disabled"
  }
}

resource "azurerm_mysql_firewall_rule" "itds_shsrv_srv_msql_fwall_rl" {
  name                = "${var.shsrv_srv_msql_fwall_rl}"
  resource_group_name = "${azurerm_resource_group.itds_shsrv_srv_msql_rg.name}"
  server_name         = "${azurerm_mysql_server.itds_shsrv_srv_msql.name}"
  start_ip_address    = "${var.vnet_start_ip}"
  end_ip_address      = "${var.vnet_end_ip}"
}