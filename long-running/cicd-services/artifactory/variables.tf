variable "env_prefix_hypon" {}

variable "env_prefix_underscore" {}

variable "env_location" {}

variable "vnet_name" {}

variable "vnet_rg_name" {}

variable "vnet_address_space" {}

variable "vnet_start_ip" {}

variable "vnet_end_ip" {}

variable "shrd_srv_artif_snet_addr_pfx" {}

variable "shrd_srv_artif_nd_stat_ip_addrs" {
  type = "list"
  default = [ "ip "]
}


variable "shrd_srv_artif_nsg_ibnd_rl" {
  type = "list"
  default = [ "22","8081","8443"]
}

variable "shrd_srv_artif_nsg_ibnd_rl_src_pfx" {
  type = "list"
  default = [ "*", "*", "*"]
}

variable "shrd_srv_artif_nsg_ibnd_rl_dst_pfx" {
  type = "list"
  default = [ "*", "*", "*"]
}

variable "shrd_srv_artif_nsg_obnd_rl" {
  type = "list"
  default = [ "22","8080","334"]
}

variable "shrd_srv_artif_nsg_obnd_rl_src_pfx" {
  type = "list"
  default = [ "*", "*", "*"]
}

variable "shrd_srv_artif_nsg_obnd_rl_dst_pfx" {
  type = "list"
  default = [ "*", "*", "*"]
}


variable "shrd_srv_artif_lb_prb_prt" {
  type = "list"
  default = [ "22","8080","334"]
}

variable "shrd_srv_artif_lb_bck_prt" {
  type = "list"
  default = [ "22","8080","334"]
}

variable "shrd_srv_artif_lb_fnt_prt" {
  type = "list"
  default = [ "22","8080","334"]
}


variable "itds_shrd_srv_artif_vm_ip" {
  type = "list"
  default = [ "172.21.32.132","172.21.32.133","172.21.32.134"]
}

variable "itds_shrd_srv_artif_vm" {
  type = "map"
  default = {
    vm_size = "Standard_F2"
    vm_img_publisher = "Canonical"
    vm_img_offer = "UbuntuServer"
    vm_img_sku = "18.04-LTS"
    vm_img_ver = "latest"
    vm_mg_dsk_ty = "Standard_LRS"
    vm_mg_dsk_sz = 1024
  }
}

variable "shrd_srv_artif_vm_adm"{}

variable "shrd_srv_artif_vm_pswd" {}