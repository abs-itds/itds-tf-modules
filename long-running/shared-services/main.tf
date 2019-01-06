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


resource "azurerm_network_security_group" "itds_shrd_srv_rdis_nsg" {
  name                = "${var.shrd_srv_rdis_nsg}"
  resource_group_name = "${azurerm_resource_group.itds_shrd_srv_rdis_rg.name}"
  location = "${var.env_location}"

  security_rule {
    name                       = "port_22"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

resource "azurerm_subnet" "itds_shrd_srv_rdis_snet" {
  name                 = "${var.shrd_srv_rdis_snet}"
  virtual_network_name = "${var.vnet_name}"
  resource_group_name  = "${var.vnet_rg_name}"
  address_prefix = "${var.shrd_srv_rdis_snet_addr_pfx}"
  network_security_group_id = "${azurerm_network_security_group.itds_shrd_srv_rdis_nsg.id}"

}

resource "azurerm_subnet_network_security_group_association" "itds_shrd_srv_rdis_snet_nsg_asso" {
  subnet_id                 = "${azurerm_subnet.itds_shrd_srv_rdis_snet.id}"
  network_security_group_id = "${azurerm_network_security_group.itds_shrd_srv_rdis_nsg.id}"
}


resource "azurerm_redis_cache" "itds_shrd_srv_rdis" {
  name                = "${var.shrd_srv_rdis}"
  location            = "${azurerm_resource_group.itds_shrd_srv_rdis_rg.location}"
  resource_group_name = "${azurerm_resource_group.itds_shrd_srv_rdis_rg.name}"
  #6GB Cache
  capacity            = 3
  family              = "C"
  sku_name            = "Basic"
  subnet_id           = "${azurerm_subnet.itds_shrd_srv_rdis_snet.id}"
  enable_non_ssl_port = false
  private_static_ip_address = "${var.shrd_srv_rdis_pvt_stat_addr}"
  ignore_changes = ["redis_configuration.0.rdb_storage_connection_string"]
  redis_configuration {
    maxmemory_policy   = "volatile-lru"
  }
}

#Allow all addresses from the VNet
resource "azurerm_redis_firewall_rule" "itds_shrd_srv_rdis_fwall_rl" {
  name                = "${var.shrd_srv_rdis_fwall_rl}"
  redis_cache_name    = "${azurerm_redis_cache.itds_shrd_srv_rdis.name}"
  resource_group_name = "${azurerm_resource_group.itds_shrd_srv_rdis_rg.name}"
  start_ip            = "${var.shrd_srv_rdis_fwall_rl_start_ip}"
  end_ip              = "${var.shrd_srv_rdis_fwall_rl_end_ip}"
}

resource "azurerm_resource_group" "itds_shrd_srv_msql_rg" {
  name     = "${var.shrd_srv_msql_rg}"
  location = "${var.env_location}"
}

resource "azurerm_network_security_group" "itds_shrd_srv_msql_nsg" {
  name                = "${var.shrd_srv_msql_nsg}"
  resource_group_name = "${azurerm_resource_group.itds_shrd_srv_msql_rg.name}"
  location = "${azurerm_resource_group.itds_shrd_srv_msql_rg.location}"

  security_rule {
    name                       = "port_6380"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6380"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

resource "azurerm_subnet" "itds_shrd_srv_msql_snet" {
  name                 = "${var.shrd_srv_msql_snet}"
  virtual_network_name = "${var.vnet_name}"
  resource_group_name  = "${var.vnet_rg_name}"
  address_prefix = "${var.shrd_srv_msql_snet_addr_pfx}"
  network_security_group_id = "${azurerm_network_security_group.itds_shrd_srv_msql_nsg.id}"
}

resource "azurerm_subnet_network_security_group_association" "itds_shrd_srv_msql_snet_nsg_asso" {
  subnet_id                 = "${azurerm_subnet.itds_shrd_srv_msql_snet.id}"
  network_security_group_id = "${azurerm_network_security_group.itds_shrd_srv_msql_nsg.id}"
}


