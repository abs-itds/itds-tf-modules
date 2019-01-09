terraform {
  backend "azurerm" {}
}

data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "itds_prob_rg" {
  name = "${var.env_prefix_hypon}-prob-rg"
  location = "${var.env_location}"
}

resource "azurerm_network_security_group" "itds_prob_nsg" {
  name = "${var.env_prefix_hypon}-prob-nsg"
  resource_group_name = "${azurerm_resource_group.itds_prob_rg.name}"
  location = "${azurerm_resource_group.itds_prob_rg.location}"

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

resource "azurerm_subnet" "itds_prob_snet" {
  name = "${var.env_prefix_hypon}-prob-snet"
  virtual_network_name = "${var.vnet_name}"
  resource_group_name = "${var.vnet_rg_name}"
  address_prefix = "${var.prob_snet_addr_pfx}"
}

resource "azurerm_subnet_network_security_group_association" "itds_prob_snet_nsg_asso" {
  subnet_id = "${azurerm_subnet.itds_prob_snet.id}"
  network_security_group_id = "${azurerm_network_security_group.itds_prob_nsg.id}"
}


resource "azurerm_public_ip" "itds_prob_pip" {
  name = "${var.env_prefix_hypon}-prob-pip"
  location = "${azurerm_resource_group.itds_prob_rg.location}"
  resource_group_name = "${azurerm_resource_group.itds_prob_rg.name}"
  public_ip_address_allocation = "static"
}

resource "azurerm_lb" "itds_prob_lb" {
  name = "${var.env_prefix_hypon}-prob-lb"
  location = "${azurerm_resource_group.itds_prob_rg.location}"
  resource_group_name = "${azurerm_resource_group.itds_prob_rg.name}"

  frontend_ip_configuration {
    name = "${var.env_prefix_hypon}-prob-lb-pip"
    public_ip_address_id = "${azurerm_public_ip.itds_prob_pip.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "itds_prob_lb_addr_pl" {
  name = "${var.env_prefix_hypon}-prob-lb-addr-pl"
  resource_group_name = "${azurerm_resource_group.itds_prob_rg.name}"
  loadbalancer_id = "${azurerm_lb.itds_prob_lb.id}"
}


resource "azurerm_availability_set" "itds_prob_aset" {
  name = "${var.env_prefix_hypon}-prob-aset"
  location = "${azurerm_resource_group.itds_prob_rg.location}"
  resource_group_name = "${azurerm_resource_group.itds_prob_rg.name}"
  managed = "true"
}


resource "azurerm_network_interface" "itds_prob_nd_01_nic" {
  name = "${var.env_prefix_hypon}-prob-nd-01-nic"
  location = "${azurerm_resource_group.itds_prob_rg.location}"
  resource_group_name = "${azurerm_resource_group.itds_prob_rg.name}"

  ip_configuration {
    name = "${var.env_prefix_hypon}-prob-nd-01-ip-conf"
    subnet_id = "${azurerm_subnet.itds_prob_snet.id}"
    private_ip_address_allocation = "static"
    private_ip_address = "${var.prob_nd_01_stat_ip_addr}"
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "itds_prob_nd_01_nic_lb_addr_pl_asso" {
  ip_configuration_name = "${var.env_prefix_hypon}-prob-nd-01-ip-conf"
  network_interface_id = "${azurerm_network_interface.itds_prob_nd_01_nic.id}"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.itds_prob_lb_addr_pl.id}"
}

resource "azurerm_virtual_machine" "itds_prob_nd_01_vm" {
  name = "${var.env_prefix_hypon}-prob-nd-01-vm"
  location = "${azurerm_resource_group.itds_prob_rg.location}"
  resource_group_name = "${azurerm_resource_group.itds_prob_rg.name}"
  network_interface_ids = [
    "${azurerm_network_interface.itds_prob_nd_01_nic.id}"]
  vm_size = "${var.prob_nd_vm_sz}"
  availability_set_id = "${azurerm_availability_set.itds_prob_aset.id}"
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "18.04-LTS"
    version = "latest"
  }

  storage_os_disk {
    name = "${var.env_prefix_hypon}-prob-nd-01-vm-dsk"
    caching = "ReadWrite"
    create_option = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name = "${var.env_prefix_hypon}-prob-nd-01-vm"
    admin_username = "${var.prob_nd_adm}"
    admin_password = "${var.prob_nd_pswd}"
    #custom_data = "${data.template_cloudinit_config.itds_prob_nd_vm_init_srpt_cfg}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "azurerm_managed_disk" "itds_prob_nd_01_dsk_01" {
  name = "${var.env_prefix_hypon}-prob-nd-01-dsk-01"
  location = "${azurerm_resource_group.itds_prob_rg.location}"
  resource_group_name = "${azurerm_resource_group.itds_prob_rg.name}"
  storage_account_type = "Premium_LRS"
  create_option = "Empty"
  disk_size_gb = 1024
}

resource "azurerm_virtual_machine_data_disk_attachment" "itds_prob_nd_01_dsk_attch" {
  managed_disk_id = "${azurerm_managed_disk.itds_prob_nd_01_dsk_01.id}"
  virtual_machine_id = "${azurerm_virtual_machine.itds_prob_nd_01_vm.id}"
  lun = "10"
  caching = "ReadWrite"
}


resource "azurerm_virtual_machine_extension" "itds_prob_nd_01_vm_ext" {
  name = "${var.env_prefix_hypon}-prob-nd-01-vm-ext"
  location = "${azurerm_resource_group.itds_prob_rg.location}"
  resource_group_name = "${azurerm_resource_group.itds_prob_rg.name}"
  virtual_machine_name = "${azurerm_virtual_machine.itds_prob_nd_01_vm.name}"
  publisher = "Microsoft.Azure.Extensions"
  type = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "commandToExecute": "hostname && uptime"
    }
SETTINGS
}
