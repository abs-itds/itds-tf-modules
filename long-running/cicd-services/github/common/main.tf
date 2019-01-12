terraform {
  backend "azurerm" {}
}

# Configure the GitHub Provider
variable "itds_github_tkn" {
  default = ""
}
variable "itds_github_org" {
  default = ""
}


provider "github" {
  token        = "${var.itds_github_tkn}"
  organization = "${var.itds_github_org}"
}


