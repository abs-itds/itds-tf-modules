terraform {
  backend "azurerm" {}
}

data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "itds_shrd_srv_demo1_rg" {
  name = "${var.env_prefix_hypon}-shrd-srv-demo1-rg"
  location = "${var.env_location}"
}

resource "azurerm_network_security_group" "itds_shrd_srv_demo1_nsg" {
  name = "${var.env_prefix_hypon}-shrd-srv-demo1-nsg"
  resource_group_name = "${azurerm_resource_group.itds_shrd_srv_demo1_rg.name}"
  location = "${azurerm_resource_group.itds_shrd_srv_demo1_rg.location}"

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

resource "azurerm_subnet" "itds_shrd_srv_demo1_snet" {
  name = "${var.env_prefix_hypon}-shrd-srv-demo1-snet"
  virtual_network_name = "${var.vnet_name}"
  resource_group_name = "${var.vnet_rg_name}"
  address_prefix = "${var.shrd_srv_demo1_snet_addr_pfx}"
}

resource "azurerm_subnet_network_security_group_association" "itds_shrd_srv_demo1_snet_nsg_asso" {
  subnet_id = "${azurerm_subnet.itds_shrd_srv_demo1_snet.id}"
  network_security_group_id = "${azurerm_network_security_group.itds_shrd_srv_demo1_nsg.id}"
}


resource "azurerm_public_ip" "itds_shrd_srv_demo1_pip" {
  name = "${var.env_prefix_hypon}-shrd-srv-demo1-pip"
  location = "${azurerm_resource_group.itds_shrd_srv_demo1_rg.location}"
  resource_group_name = "${azurerm_resource_group.itds_shrd_srv_demo1_rg.name}"
  public_ip_address_allocation = "static"
}

resource "azurerm_lb" "itds_shrd_srv_demo1_lb" {
  name = "${var.env_prefix_hypon}-shrd-srv-demo1-lb"
  location = "${azurerm_resource_group.itds_shrd_srv_demo1_rg.location}"
  resource_group_name = "${azurerm_resource_group.itds_shrd_srv_demo1_rg.name}"

  frontend_ip_configuration {
    name = "${var.env_prefix_hypon}-shrd-srv-demo1-lb-pip"
    public_ip_address_id = "${azurerm_public_ip.itds_shrd_srv_demo1_pip.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "itds_shrd_srv_demo1_lb_addr_pl" {
  name = "${var.env_prefix_hypon}-shrd-srv-demo1-lb-addr-pl"
  resource_group_name = "${azurerm_resource_group.itds_shrd_srv_demo1_rg.name}"
  loadbalancer_id = "${azurerm_lb.itds_shrd_srv_demo1_lb.id}"
}


resource "azurerm_availability_set" "itds_shrd_srv_demo1_aset" {
  name = "${var.env_prefix_hypon}-shrd-srv-demo1-aset"
  location = "${azurerm_resource_group.itds_shrd_srv_demo1_rg.location}"
  resource_group_name = "${azurerm_resource_group.itds_shrd_srv_demo1_rg.name}"
  managed = "true"
}


resource "azurerm_network_interface" "itds_shrd_srv_demo1_nd_01_nic" {
  name = "${var.env_prefix_hypon}-shrd-srv-demo1-nd-01-nic"
  location = "${azurerm_resource_group.itds_shrd_srv_demo1_rg.location}"
  resource_group_name = "${azurerm_resource_group.itds_shrd_srv_demo1_rg.name}"

  ip_configuration {
    name = "${var.env_prefix_hypon}-shrd-srv-demo1-nd-01-ip-conf"
    subnet_id = "${azurerm_subnet.itds_shrd_srv_demo1_snet.id}"
    private_ip_address_allocation = "static"
    private_ip_address = "${var.shrd_srv_demo1_nd_01_stat_ip_addr}"
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "itds_shrd_srv_demo1_nd_01_nic_lb_addr_pl_asso" {
  ip_configuration_name = "${var.env_prefix_hypon}-shrd-srv-demo1-nd-01-ip-conf"
  network_interface_id = "${azurerm_network_interface.itds_shrd_srv_demo1_nd_01_nic.id}"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.itds_shrd_srv_demo1_lb_addr_pl.id}"
}

resource "azurerm_virtual_machine" "itds_shrd_srv_demo1_nd_01_vm" {
  name = "${var.env_prefix_hypon}-shrd-srv-demo1-nd-01-vm"
  location = "${azurerm_resource_group.itds_shrd_srv_demo1_rg.location}"
  resource_group_name = "${azurerm_resource_group.itds_shrd_srv_demo1_rg.name}"
  network_interface_ids = [
    "${azurerm_network_interface.itds_shrd_srv_demo1_nd_01_nic.id}"]
  vm_size = "${var.shrd-srv-demo1-nd-vm-sz}"
  availability_set_id = "${azurerm_availability_set.itds_shrd_srv_demo1_aset.id}"
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "18.04-LTS"
    version = "latest"
  }

  storage_os_disk {
    name = "${var.env_prefix_hypon}-shrd-srv-demo1-nd-01-vm-dsk"
    caching = "ReadWrite"
    create_option = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name = "${var.env_prefix_hypon}-shrd-srv-demo1-nd-01-vm"
    admin_username = "${var.shrd_srv_demo1_nd_adm}"
    admin_password = "${var.shrd_srv_demo1_nd_pswd}"
    #custom_data = "${data.template_cloudinit_config.itds_shrd_srv_demo1_nd_vm_init_srpt_cfg}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "azurerm_managed_disk" "itds_shrd_srv_demo1_nd_01_dsk_01" {
  name = "${var.env_prefix_hypon}-shrd-srv-demo1-nd-01-dsk-01"
  location = "${azurerm_resource_group.itds_shrd_srv_demo1_rg.location}"
  resource_group_name = "${azurerm_resource_group.itds_shrd_srv_demo1_rg.name}"
  storage_account_type = "Premium_LRS"
  create_option = "Empty"
  disk_size_gb = 1024
}

resource "azurerm_virtual_machine_data_disk_attachment" "itds_shrd_srv_demo1_nd_01_dsk_attch" {
  managed_disk_id = "${azurerm_managed_disk.itds_shrd_srv_demo1_nd_01_dsk_01.id}"
  virtual_machine_id = "${azurerm_virtual_machine.itds_shrd_srv_demo1_nd_01_vm.id}"
  lun = "10"
  caching = "ReadWrite"
}


resource "azurerm_virtual_machine_extension" "itds_shrd_srv_demo1_nd_01_vm_ext" {
  name = "${var.env_prefix_hypon}-shrd-srv-demo1-nd-01-vm-ext"
  location = "${azurerm_resource_group.itds_shrd_srv_demo1_rg.location}"
  resource_group_name = "${azurerm_resource_group.itds_shrd_srv_demo1_rg.name}"
  virtual_machine_name = "${azurerm_virtual_machine.itds_shrd_srv_demo1_nd_01_vm.name}"
  publisher = "Microsoft.Azure.Extensions"
  type = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "commandToExecute": "hostname && uptime"
    }
SETTINGS
}

