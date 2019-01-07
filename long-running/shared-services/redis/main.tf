terraform {
  backend "azurerm" {}
}

data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "itds_shsrv_srv_rdis_rg" {
  name     = "${var.env_prefix_hypon}-shsrv-srv-rdis-rg"
  location = "${var.env_location}"
}

resource "azurerm_redis_cache" "itds_shsrv_srv_rdis" {
  name                = "${var.env_prefix_hypon}-shsrv-srv-rdis"
  location            = "${azurerm_resource_group.itds_shsrv_srv_rdis_rg.location}"
  resource_group_name = "${azurerm_resource_group.itds_shsrv_srv_rdis_rg.name}"
  capacity            = 3
  family              = "C"
  sku_name            = "Basic"
  enable_non_ssl_port = false
  redis_configuration {
    maxmemory_policy   = "volatile-lru"
  }
}

#Allow all addresses from the VNet
resource "azurerm_redis_firewall_rule" "itds_shsrv_srv_rdis_fwall_rl" {
  name                = "${var.shsrv_srv_rdis_fwall_rl}"
  redis_cache_name    = "${azurerm_redis_cache.itds_shsrv_srv_rdis.name}"
  resource_group_name = "${azurerm_resource_group.itds_shsrv_srv_rdis_rg.name}"
  start_ip            = "${var.vnet_start_ip}"
  end_ip              = "${var.vnet_end_ip}"
}

