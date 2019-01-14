terraform {
  backend "azurerm" {}
}

data "azurerm_subscription" "current" {}

resource "azurerm_role_definition" "itds_iam_dvlpr_rl" {
  name        = "${var.env_prefix_hypon}-iam-dvlpr-rl"
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
  name        = "${var.env_prefix_hypon}-iam-bi-eng-rl"
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
  name        = "${var.env_prefix_hypon}-iam-dstist-rl"
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
  name        = "${var.env_prefix_hypon}-iam-dops-eng-rl"
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
  name        = "${var.env_prefix_hypon}-iam-qa-rl"
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
  name        = "${var.env_prefix_hypon}-iam-suprt-eng-rl"
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
