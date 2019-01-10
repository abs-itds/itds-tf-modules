terraform {
  backend "azurerm" {}
}

data "azurerm_subscription" "current" {}

data "azurerm_virtual_network" "itds_vnet" {
  name = "${var.vnet_name}"
  resource_group_name = "${var.vnet_rg_name}"
}

resource "azurerm_resource_group" "itds_hdi_kfka_rg" {
  name = "${var.env_prefix_hypon}-hdi-kfka-rg"
  location = "${var.env_location}"
}

resource "azurerm_network_security_group" "itds_hdi_kfka_nsg" {
  name = "${var.env_prefix_hypon}-hdi-kfka-nsg"
  resource_group_name = "${azurerm_resource_group.itds_hdi_kfka_rg.name}"
  location = "${azurerm_resource_group.itds_hdi_kfka_rg.location}"

  security_rule {
    name = "port_any"
    priority = 200
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "*"
    source_address_prefix = "${var.vnet_address_space}"
    destination_address_prefix = "*"
  }

  security_rule {
    name = "port_443_inbound_168_61_49_99"
    priority = 130
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "443"
    source_address_prefix = "168.61.49.99"
    destination_address_prefix = "*"
  }

  security_rule {
    name = "port_443_inbound_23_99_5_239"
    priority = 140
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "443"
    source_address_prefix = "23.99.5.239"
    destination_address_prefix = "*"
  }

  security_rule {
    name = "port_443_inbound_168_61_48_131"
    priority = 150
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "443"
    source_address_prefix = "168.61.48.131"
    destination_address_prefix = "*"
  }

  security_rule {
    name = "port_443_inbound_138_91_141_162"
    priority = 160
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "443"
    source_address_prefix = "138.91.141.162"
    destination_address_prefix = "*"
  }

  security_rule {
    name = "port_443_inbound_13_64_254_98"
    priority = 170
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "443"
    source_address_prefix = "13.64.254.98"
    destination_address_prefix = "*"
  }

  security_rule {
    name = "port_443_inbound_23_101_196_19"
    priority = 180
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "443"
    source_address_prefix = "23.101.196.19"
    destination_address_prefix = "*"
  }

  security_rule {
    name = "port_443_inbound_168_63_129_16"
    priority = 190
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "*"
    source_address_prefix = "168.63.129.16"
    destination_address_prefix = "*"
  }

}

resource "azurerm_subnet" "itds_hdi_kfka_snet" {
  name = "${var.env_prefix_hypon}-hdi-kfka-snet"
  virtual_network_name = "${var.vnet_name}"
  resource_group_name = "${var.vnet_rg_name}"
  address_prefix = "${var.hdi_kfka_snet_addr_pfx}"
}

resource "azurerm_subnet_network_security_group_association" "itds_hdi_kfka_snet_nsg_asso" {
  subnet_id = "${azurerm_subnet.itds_hdi_kfka_snet.id}"
  network_security_group_id = "${azurerm_network_security_group.itds_hdi_kfka_nsg.id}"

  provisioner "local-exec" {
    command = "az hdinsight create --name \"${var.env_prefix_hypon}-hdi-kfka\" --resource-group \"${azurerm_resource_group.itds_hdi_kfka_rg.name}\" --cluster-tier \"${var.hdi_clus_tir}\" --headnode-size \"${var.hdi_kfka_hd_nd_sz}\" --http-password \"${var.hdi_kfka_htp_usr_pwd}\" --http-user \"${var.hdi_kfka_htp_usr}\" --location \"westus\" --size \"${var.hdi_kfka_wk_nd_cnt}\" --ssh-public-key \"${var.hdi_kfka_ssh_pub_ky}\" --ssh-user \"${var.hdi_kfka_ssh_user}\" --storage-account \"${var.shsrv_sa}.blob.core.windows.net\" --storage-account-key \"${var.env_prefix_hypon}-hdi-kfka-sa-key\" --subnet-name \"${azurerm_subnet.itds_hdi_kfka_snet.id}\" --subscription \"Abs-ITDS-Dev\" --type kafka --version \"${var.hdi_version}\" --virtual-network \"${data.azurerm_virtual_network.itds_vnet.id}\" --workernode-data-disk-size \"${var.hdi_kfka_wrk_nd_dsk_sz}\" --workernode-data-disk-storage-account-type premium_lrs --workernode-data-disks-per-node \"${var.hdi_kfka_wrk_nd_dsks_cnt}\" --workernode-size \"${var.hdi_kfka_wrk_nd_sz}\" --zookeepernode-size \"${var.hdi_kfka_zk_nd_sz}\" --debug"
  }
}

