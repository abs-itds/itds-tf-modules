terraform {
  backend "azurerm" {}
}

data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "itds_shrd_srv_hue_rg" {
  name = "${var.env_prefix_hypon}-shrd-srv-hue-rg"
  location = "${var.env_location}"
}

resource "azurerm_network_security_group" "itds_shrd_srv_hue_nsg" {
  name = "${var.env_prefix_hypon}-shrd-srv-hue-nsg"
  resource_group_name = "${azurerm_resource_group.itds_shrd_srv_hue_rg.name}"
  location = "${azurerm_resource_group.itds_shrd_srv_hue_rg.location}"

  security_rule {
    name = "port_22"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "22"
    source_address_prefix = "${var.vnet_address_space}"
    destination_address_prefix = "*"
  }

}

resource "azurerm_subnet" "itds_shrd_srv_hue_snet" {
  name = "${var.env_prefix_hypon}-shrd-srv-hue-snet"
  virtual_network_name = "${var.vnet_name}"
  resource_group_name = "${var.vnet_rg_name}"
  address_prefix = "${var.shrd_srv_hue_snet_addr_pfx}"
}

resource "azurerm_subnet_network_security_group_association" "itds_shrd_srv_hue_snet_nsg_asso" {
  subnet_id = "${azurerm_subnet.itds_shrd_srv_hue_snet.id}"
  network_security_group_id = "${azurerm_network_security_group.itds_shrd_srv_hue_nsg.id}"
}


resource "azurerm_public_ip" "itds_shrd_srv_hue_pip" {
  name = "${var.env_prefix_hypon}-shrd-srv-hue-pip"
  location = "${azurerm_resource_group.itds_shrd_srv_hue_rg.location}"
  resource_group_name = "${azurerm_resource_group.itds_shrd_srv_hue_rg.name}"
  public_ip_address_allocation = "static"
}

resource "azurerm_lb" "itds_shrd_srv_hue_lb" {
  name = "${var.env_prefix_hypon}-shrd-srv-hue-lb"
  location = "${azurerm_resource_group.itds_shrd_srv_hue_rg.location}"
  resource_group_name = "${azurerm_resource_group.itds_shrd_srv_hue_rg.name}"

  frontend_ip_configuration {
    name = "${var.env_prefix_hypon}-shrd-srv-hue-lb-pip}"
    public_ip_address_id = "${azurerm_public_ip.itds_shrd_srv_hue_pip.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "itds_shrd_srv_hue_lb_addr_pl" {
  name = "${var.env_prefix_hypon}-shrd-srv-hue-lb-addr-pl"
  resource_group_name = "${azurerm_resource_group.itds_shrd_srv_hue_rg.name}"
  loadbalancer_id = "${azurerm_lb.itds_shrd_srv_hue_lb.id}"
}


resource "azurerm_availability_set" "itds_shrd_srv_hue_aset" {
  name = "${var.env_prefix_hypon}-shrd-srv-hue-aset"
  location = "${azurerm_resource_group.itds_shrd_srv_hue_rg.location}"
  resource_group_name = "${azurerm_resource_group.itds_shrd_srv_hue_rg.name}"
  managed = "true"
}


resource "azurerm_network_interface" "itds_shrd_srv_hue_nd_01_nic" {
  name = "${var.env_prefix_hypon}-shrd-srv-hue-nd-01-nic"
  location = "${azurerm_resource_group.itds_shrd_srv_hue_rg.location}"
  resource_group_name = "${azurerm_resource_group.itds_shrd_srv_hue_rg.name}"

  ip_configuration {
    name = "${var.env_prefix_hypon}-shrd-srv-hue-nd-01-ip-conf"
    subnet_id = "${azurerm_subnet.itds_shrd_srv_hue_snet.id}"
    private_ip_address_allocation = "static"
    private_ip_address = "${var.shrd_srv_hue_nd_01_stat_ip_addr}"
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "itds_shrd_srv_hue_nd_01_nic_lb_addr_pl_asso" {
  ip-configuration-name = "${var.env_prefix_hypon}-shrd-srv-hue-nic-lb-addr-pl-asso"
  network_interface_id = "${azurerm_network_interface.itds_shrd_srv_hue_nd_01_nic.id}"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.itds_shrd_srv_hue_lb_addr_pl.id}"
}


resource "azurerm_virtual_machine" "itds_shrd_srv_hue_nd_01_vm" {
  name = "${var.env_prefix_hypon}-shrd-srv-hue-nd-01-vm"
  location = "${azurerm_resource_group.itds_shrd_srv_hue_rg.location}"
  resource_group_name = "${azurerm_resource_group.itds_shrd_srv_hue_rg.name}"
  network_interface_ids = [
    "${azurerm_network_interface.itds_shrd_srv_hue_nd_01_nic.id}"]
  vm_size = "Standard_F2"
  availability_set_id = "${azurerm_availability_set.itds_shrd_srv_hue_aset.id}"
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "18.04-LTS"
    version = "latest"
  }

  storage_os_disk {
    name = "${var.env_prefix_hypon}-shrd-srv-hue-nd-01-vm-dsk"
    caching = "ReadWrite"
    create_option = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name = "${var.env_prefix_underscore}_shrd_srv_hue_nd_01_vm"
    admin_username = "${var.shrd_srv_hue_nd_adm}"
    admin_password = "${var.shrd_srv_hue_nd_pswd}"
    #custom_data = ""
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "azurerm_managed_disk" "itds_shrd_srv_hue_nd_01_dsk_01" {
  name = "${var.env_prefix_hypon}-shrd-srv-hue-nd-01-dsk-01"
  location = "${azurerm_resource_group.itds_shrd_srv_hue_rg.location}"
  resource_group_name = "${azurerm_resource_group.itds_shrd_srv_hue_rg.name}"
  storage_account_type = "Standard_LRS"
  create_option = "Empty"
  disk_size_gb = 1024
}

resource "azurerm_virtual_machine_data_disk_attachment" "itds_shrd_srv_hue_nd_01_dsk_attch" {
  managed_disk_id = "${azurerm_managed_disk.itds_shrd_srv_hue_nd_01_dsk_01.id}"
  virtual_machine_id = "${azurerm_virtual_machine.itds_shrd_srv_hue_nd_01_vm.id}"
  lun = "10"
  caching = "ReadWrite"
}


resource "azurerm_virtual_machine_extension" "itds_shrd_srv_hue_nd_01_vm_ext" {
  name = "${var.env_prefix_hypon}-shrd-srv-hue-nd-01-vm-ext"
  location = "${azurerm_resource_group.itds_shrd_srv_hue_rg.location}"
  resource_group_name = "${azurerm_resource_group.itds_shrd_srv_hue_rg.name}"
  virtual_machine_name = "${azurerm_virtual_machine.itds_shrd_srv_hue_nd_01_vm.name}"
  publisher = "Microsoft.Azure.Extensions"
  type = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "commandToExecute": "sudo apt-get update && sudo apt-get install docker-ce  "
    }
SETTINGS
}


# Node 02

resource "azurerm_network_interface" "itds_shrd_srv_hue_nd_02_nic" {
  name = "${var.env_prefix_hypon}-shrd-srv-hue-nd-02-nic"
  location = "${azurerm_resource_group.itds_shrd_srv_hue_rg.location}"
  resource_group_name = "${azurerm_resource_group.itds_shrd_srv_hue_rg.name}"

  ip_configuration {
    name = "${var.env_prefix_hypon}_shrd_srv_hue_nd_02_ip_conf"
    subnet_id = "${azurerm_subnet.itds_shrd_srv_hue_snet.id}"
    private_ip_address_allocation = "static"
    private_ip_address = "${var.shrd_srv_hue_nd_02_stat_ip_addr}"
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "itds_shrd_srv_hue_nd_02_nic_lb_addr_pl_asso" {
  ip-configuration-name = "${var.env_prefix_hypon}-shrd-srv-hue-nic-lb-addr-pl-asso"
  network_interface_id = "${azurerm_network_interface.itds_shrd_srv_hue_nd_02_nic.id}"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.itds_shrd_srv_hue_lb_addr_pl.id}"
}


resource "azurerm_virtual_machine" "itds_shrd_srv_hue_nd_02_vm" {
  name = "${var.env_prefix_hypon}-shrd-srv-hue-nd-02-vm"
  location = "${azurerm_resource_group.itds_shrd_srv_hue_rg.location}"
  resource_group_name = "${azurerm_resource_group.itds_shrd_srv_hue_rg.name}"
  network_interface_ids = [
    "${azurerm_network_interface.itds_shrd_srv_hue_nd_02_nic.id}"]
  vm_size = "Standard_F2"
  availability_set_id = "${azurerm_availability_set.itds_shrd_srv_hue_aset.id}"
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "18.04-LTS"
    version = "latest"
  }

  storage_os_disk {
    name = "${var.env_prefix_hypon}-shrd-srv-hue-nd-02-vm-dsk"
    caching = "ReadWrite"
    create_option = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name = "${var.env_prefix_underscore}_shrd_srv_hue_nd_02_vm"
    admin_username = "${var.shrd_srv_hue_nd_adm}"
    admin_password = "${var.shrd_srv_hue_nd_pswd}"
    #custom_data = ""
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "azurerm_managed_disk" "itds_shrd_srv_hue_nd_02_dsk_01" {
  name = "${var.env_prefix_hypon}-shrd-srv-hue-nd-02-dsk-01"
  location = "${azurerm_resource_group.itds_shrd_srv_hue_rg.location}"
  resource_group_name = "${azurerm_resource_group.itds_shrd_srv_hue_rg.name}"
  storage_account_type = "Standard_LRS"
  create_option = "Empty"
  disk_size_gb = 1024
}

resource "azurerm_virtual_machine_data_disk_attachment" "itds_shrd_srv_hue_nd_02_dsk_attch" {
  managed_disk_id = "${azurerm_managed_disk.itds_shrd_srv_hue_nd_02_dsk_01.id}"
  virtual_machine_id = "${azurerm_virtual_machine.itds_shrd_srv_hue_nd_02_vm.id}"
  lun = "10"
  caching = "ReadWrite"
}


resource "azurerm_virtual_machine_extension" "itds_shrd_srv_hue_nd_02_vm_ext" {
  name = "${var.env_prefix_hypon}-shrd-srv-hue-nd-02-vm-ext"
  location = "${azurerm_resource_group.itds_shrd_srv_hue_rg.location}"
  resource_group_name = "${azurerm_resource_group.itds_shrd_srv_hue_rg.name}"
  virtual_machine_name = "${azurerm_virtual_machine.itds_shrd_srv_hue_nd_02_vm.name}"
  publisher = "Microsoft.Azure.Extensions"
  type = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "commandToExecute": "sudo apt-get update && sudo apt-get install docker-ce  "
    }
SETTINGS
}


resource "azurerm_network_interface" "itds_shrd_srv_hue_nd_03_nic" {
  name = "${var.env_prefix_hypon}-shrd-srv-hue-nd-03-nic"
  location = "${azurerm_resource_group.itds_shrd_srv_hue_rg.location}"
  resource_group_name = "${azurerm_resource_group.itds_shrd_srv_hue_rg.name}"

  ip_configuration {
    name = "${var.env_prefix_hypon}-shrd-srv-hue-nd-03-ip-conf"
    subnet_id = "${azurerm_subnet.itds_shrd_srv_hue_snet.id}"
    private_ip_address_allocation = "static"
    private_ip_address = "${var.shrd_srv_hue_nd_03_stat_ip_addr}"
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "itds_shrd_srv_hue_nd_03_nic_lb_addr_pl_asso" {
  ip-configuration-name = "${var.env_prefix_hypon}-shrd-srv-hue-nic-lb-addr-pl-asso"
  network_interface_id = "${azurerm_network_interface.itds_shrd_srv_hue_nd_03_nic.id}"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.itds_shrd_srv_hue_lb_addr_pl.id}"
}


resource "azurerm_virtual_machine" "itds_shrd_srv_hue_nd_03_vm" {
  name = "${var.env_prefix_hypon}-shrd-srv-hue-nd-03-vm"
  location = "${azurerm_resource_group.itds_shrd_srv_hue_rg.location}"
  resource_group_name = "${azurerm_resource_group.itds_shrd_srv_hue_rg.name}"
  network_interface_ids = [
    "${azurerm_network_interface.itds_shrd_srv_hue_nd_03_nic.id}"]
  vm_size = "Standard_F2"
  availability_set_id = "${azurerm_availability_set.itds_shrd_srv_hue_aset.id}"
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "18.04-LTS"
    version = "latest"
  }

  storage_os_disk {
    name = "${var.env_prefix_hypon}-shrd-srv-hue-nd-03-vm-dsk"
    caching = "ReadWrite"
    create_option = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name = "${var.env_prefix_underscore}_shrd_srv_hue_nd_03_vm"
    admin_username = "${var.shrd_srv_hue_nd_adm}"
    admin_password = "${var.shrd_srv_hue_nd_pswd}"
    #custom_data = ""
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "azurerm_managed_disk" "itds_shrd_srv_hue_nd_03_dsk_01" {
  name = "${var.env_prefix_hypon}-shrd-srv-hue-nd-03-dsk-01"
  location = "${azurerm_resource_group.itds_shrd_srv_hue_rg.location}"
  resource_group_name = "${azurerm_resource_group.itds_shrd_srv_hue_rg.name}"
  storage_account_type = "Standard_LRS"
  create_option = "Empty"
  disk_size_gb = 1024
}

resource "azurerm_virtual_machine_data_disk_attachment" "itds_shrd_srv_hue_nd_03_dsk_attch" {
  managed_disk_id = "${azurerm_managed_disk.itds_shrd_srv_hue_nd_03_dsk_01.id}"
  virtual_machine_id = "${azurerm_virtual_machine.itds_shrd_srv_hue_nd_03_vm.id}"
  lun = "10"
  caching = "ReadWrite"
}

resource "azurerm_virtual_machine_extension" "itds_shrd_srv_hue_nd_03_vm_ext" {
  name = "${var.env_prefix_hypon}-shrd-srv-hue-nd-03-vm-ext"
  location = "${azurerm_resource_group.itds_shrd_srv_hue_rg.location}"
  resource_group_name = "${azurerm_resource_group.itds_shrd_srv_hue_rg.name}"
  virtual_machine_name = "${azurerm_virtual_machine.itds_shrd_srv_hue_nd_03_vm.name}"
  publisher = "Microsoft.Azure.Extensions"
  type = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "commandToExecute": "sudo apt-get update && sudo apt-get install docker-ce  "
    }
SETTINGS
}