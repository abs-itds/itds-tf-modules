terraform {
  backend "azurerm" {}
}

data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "itds_shsrv_srv_msql_rg" {
  name = "${var.env_prefix_hypon}-shsrv-srv-msql-rg"
  location = "${var.env_location}"
}

resource "azurerm_mysql_server" "itds_shsrv_srv_msql" {
  name = "${var.env_prefix_hypon}-shsrv-srv-msql"
  location = "${azurerm_resource_group.itds_shsrv_srv_msql_rg.location}"
  resource_group_name = "${azurerm_resource_group.itds_shsrv_srv_msql_rg.name}"
  administrator_login = "${var.shsrv_srv_msql_adm_usr}"
  administrator_login_password = "${var.shsrv_srv_msql_adm_pswd}"
  version = "${var.shrd_srv_msql["msql_version"]}"
  ssl_enforcement = "Enabled"

  sku {
    name = "${var.shrd_srv_msql["msql_sku_name"]}"
    capacity = "${var.shrd_srv_msql["msql_sku_capacity"]}"
    tier = "${var.shrd_srv_msql["msql_sku_tier"]}"
    family = "${var.shrd_srv_msql["msql_sku_fam"]}"
  }

  storage_profile {
    storage_mb = "${var.shrd_srv_msql["msql_strg_mb"]}"
    backup_retention_days = "${var.shrd_srv_msql["msql_bkup_ret_dys"]}"
    geo_redundant_backup = "${var.shrd_srv_msql["msql_geo_red_bkup"]}"
  }
}

resource "azurerm_mysql_firewall_rule" "itds_shsrv_srv_msql_fwall_rl" {
  name = "${var.env_prefix_alph_num}AllowEntireVNetIPRange"
  resource_group_name = "${azurerm_resource_group.itds_shsrv_srv_msql_rg.name}"
  server_name = "${azurerm_mysql_server.itds_shsrv_srv_msql.name}"
  start_ip_address = "${var.vnet_start_ip}"
  end_ip_address = "${var.vnet_end_ip}"
}