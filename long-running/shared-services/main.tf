terraform {
  backend "azurerm" {}
}

data "azurerm_subscription" "current" {}

resource "azurerm_role_definition" "itds_iam_dvlpr_rl" {
  name        = "${var.iam_dvlpr_rl}"
  scope       = "${data.azurerm_subscription.current.id}"
  description = "ITDS Developer role"

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    "${data.azurerm_subscription.current.id}"
  ]
}

resource "azurerm_role_definition" "itds_iam_bi_eng_rl" {
  name        = "${var.iam_bi_eng_rl}"
  scope       = "${data.azurerm_subscription.current.id}"
  description = "ITDS BI Engineer role"

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    "${data.azurerm_subscription.current.id}"
  ]
}

resource "azurerm_role_definition" "itds_iam_dstist_rl" {
  name        = "${var.iam_dstist_rl}"
  scope       = "${data.azurerm_subscription.current.id}"
  description = "ITDS Data Scientist role"

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    "${data.azurerm_subscription.current.id}"
  ]
}

resource "azurerm_role_definition" "itds_iam_dops_eng_rl" {
  name        = "${var.iam_dops_eng_rl}"
  scope       = "${data.azurerm_subscription.current.id}"
  description = "ITDS DevOps Engineer role"

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    "${data.azurerm_subscription.current.id}"
  ]
}

resource "azurerm_role_definition" "itds_iam_qa_rl" {
  name        = "${var.iam_qa_rl}"
  scope       = "${data.azurerm_subscription.current.id}"
  description = "ITDS QA role"

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    "${data.azurerm_subscription.current.id}"
  ]
}

resource "azurerm_role_definition" "itds_iam_suprt_eng_rl" {
  name        = "${var.iam_suprt_eng_rl}"
  scope       = "${data.azurerm_subscription.current.id}"
  description = "ITDS Support Engineer role"

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    "${data.azurerm_subscription.current.id}"
  ]
}

resource "azurerm_resource_group" "itds_shrd_srv_rdis_rg" {
  name     = "${var.shrd_srv_rdis_rg}"
  location = "${var.env_location}"
}

resource "azurerm_redis_cache" "itds_shrd_srv_rdis" {
  name                = "${var.shrd_srv_rdis}"
  location            = "${azurerm_resource_group.itds_shrd_srv_rdis_rg.location}"
  resource_group_name = "${azurerm_resource_group.itds_shrd_srv_rdis_rg.name}"
  #6GB Cache
  capacity            = 3
  family              = "C"
  sku_name            = "Basic"
  enable_non_ssl_port = false
  redis_configuration {
    maxmemory_policy   = "volatile-lru"
  }
}

#Allow all addresses from the VNet
resource "azurerm_redis_firewall_rule" "itds_shrd_srv_rdis_fwall_rl" {
  name                = "${var.shrd_srv_rdis_fwall_rl}"
  redis_cache_name    = "${azurerm_redis_cache.itds_shrd_srv_rdis.name}"
  resource_group_name = "${azurerm_resource_group.itds_shrd_srv_rdis_rg.name}"
  start_ip            = "${var.vnet_start_ip}"
  end_ip              = "${var.vnet_end_ip}"
}

resource "azurerm_resource_group" "itds_shrd_srv_msql_rg" {
  name     = "${var.shrd_srv_msql_rg}"
  location = "${var.env_location}"
}

resource "azurerm_mysql_server" "itds_shrd_srv_msql" {
  name                         = "${var.shrd_srv_msql}"
  location                     = "${azurerm_resource_group.itds_shrd_srv_msql_rg.location}"
  resource_group_name          = "${azurerm_resource_group.itds_shrd_srv_msql_rg.name}"
  administrator_login          = "${var.shrd_srv_msql_adm_usr}"
  administrator_login_password = "${var.shrd_srv_msql_adm_pswd}"
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

resource "azurerm_mysql_firewall_rule" "itds_shrd_srv_msql_fwall_rl" {
  name                = "${var.shrd_srv_msql_fwall_rl}"
  resource_group_name = "${azurerm_resource_group.itds_shrd_srv_msql_rg.name}"
  server_name         = "${azurerm_mysql_server.itds_shrd_srv_msql.name}"
  start_ip_address    = "${var.vnet_start_ip}"
  end_ip_address      = "${var.vnet_end_ip}"
}