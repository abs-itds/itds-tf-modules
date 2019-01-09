terraform {
  backend "azurerm" {}
}

data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "itds_hdi_kfka_rg" {
  name = "${var.env_prefix_hypon}-itds-hdi-kfka-rg"
  location = "${var.env_location}"
}

resource "azurerm_network_security_group" "itds_hdi_kfka_nsg" {
  name = "${var.env_prefix_hypon}-hdi-kfka-nsg"
  resource_group_name = "${azurerm_resource_group.itds_hdi_kfka_rg.name}"
  location = "${azurerm_resource_group.itds_hdi_kfka_rg.location}"

  security_rule {
    name = "port_any"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "*"
    source_address_prefix = "${var.vnet_address_space}"
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
}

"az hdinsight create --name ${var.env_prefix_hypon}-itds-hdi-kfka  --resource-group ${azurerm_resource_group.itds_hdi_kfka_rg.name} --location ${azurerm_resource_group.itds_hdi_kfka_rg.location} "


provisioner "local-exec" {
  command = "az extension add --name storage-preview && az storage account create --name ${var.shsrv_sa} --resource-group ${azurerm_resource_group.itds_rg.name} --kind StorageV2 --hierarchical-namespace --https-only true --assign-identity --sku Standard_LRS"
}



