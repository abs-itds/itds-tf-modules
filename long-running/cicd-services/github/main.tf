terraform {
  backend "azurerm" {}
}

provider "github" {
  token = "${var.itds_github_tkn}"
  organization = "${var.itds_github_org}"
}

module "itds-project-13" {
  source = "project"
  itds_github_org = "${var.itds_github_org}"
  itds_github_prj_nm = "itds-project-13"
  itds_github_prj_repo_dply_ky = "${var.itds_github_prj_keys_fldr}/itds-project-13/deploy/id_rsa.pub"
  itds_github_tkn = "${var.itds_github_tkn}"
}

module "itds-project-14" {
  source = "project"
  itds_github_org = "${var.itds_github_org}"
  itds_github_prj_nm = "itds-project-14"
  itds_github_prj_repo_dply_ky = "${var.itds_github_prj_keys_fldr}/itds-project-14/deploy/id_rsa.pub"
  itds_github_tkn = "${var.itds_github_tkn}"
}




