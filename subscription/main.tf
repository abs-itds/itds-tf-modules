terraform {
  backend "azurerm" {}
}

data "azurerm_subscription" "current" {}

resource "azurerm_management_lock" "itds_subs_lk" {
  name       = "${var.env_prefix_hypon}-subs-lk"
  scope      = "${data.azurerm_subscription.current.id}"
  lock_level = "CanNotDelete"
  notes      = "${data.azurerm_subscription.current.display_name} subscription can not be deleted"
}

#Azure Policy Assignments
resource "azurerm_policy_assignment" "itds_subs_tag-plcy-asgn-env" {
  name                 = "${var.env_prefix_hypon}--subs-env-tg"
  scope                = "${data.azurerm_subscription.current.id}"
  #apply tag and its default value policy definition
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/2a0e14a6-b0a6-4fab-991a-187a4f81c498"
  display_name         = "Apply Environment tag and ${var.env_name} as its default value"
  depends_on = ["azurerm_management_lock.itds_subs_lk"]
  parameters = <<PARAMETERS
  {
    "tagName" : {
      "value" : "environment"
    },
    "tagValue" : {
      "value" : "${var.env_name}"
    }
  }
  PARAMETERS
}

resource "azurerm_policy_assignment" "itds_subs_tag-plcy-asgn-grp" {
  name                 = "${var.env_prefix_hypon}-subs-grp-tg"
  scope                = "${data.azurerm_subscription.current.id}"
  #apply tag and its default value policy definition
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/2a0e14a6-b0a6-4fab-991a-187a4f81c498"
  display_name         = "Apply Environment tag and ${var.env_group} as its default value"
  depends_on = ["azurerm_management_lock.itds_subs_lk"]
  parameters = <<PARAMETERS
  {
    "tagName" : {
      "value" : "group"
    },
    "tagValue" : {
      "value" : "${var.env_group}"
    }
  }
  PARAMETERS
}

resource "azurerm_policy_assignment" "itds_subs_tag-plcy-asgn-admins" {
  name                 = "${var.env_prefix_hypon}-subs-adms-tg"
  scope                = "${data.azurerm_subscription.current.id}"
  #apply tag and its default value policy definition
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/2a0e14a6-b0a6-4fab-991a-187a4f81c498"
  display_name         = "Apply Environment tag and ${var.env_admins} as its default value"
  depends_on = ["azurerm_management_lock.itds_subs_lk"]
  parameters = <<PARAMETERS
  {
    "tagName" : {
      "value" : "admins"
    },
    "tagValue" : {
      "value" : "${var.env_admins}"
    }
  }
  PARAMETERS
}


resource "azurerm_policy_assignment" "itds_subs_tag-plcy-asgn-allwd-loc" {
  name                 = "${var.env_prefix_hypon}-subs-allwd-loc-tg"
  scope                = "${data.azurerm_subscription.current.id}"
  #apply tag and its default value policy definition
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c"
  display_name         = "Restrict location for all resources to ${var.env_location}"
  depends_on = ["azurerm_management_lock.itds_subs_lk"]
  parameters = <<PARAMETERS
  {
    "listOfAllowedLocations": {
      "value": [ "${var.env_location}" ]
    }
  }
  PARAMETERS
}
