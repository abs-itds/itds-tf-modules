terraform {
  backend "azurerm" {}
}
data "azurerm_subscription" "current" {}

resource "azurerm_management_lock" "itds_subs_lk" {
  name       = "${var.subs_lk_name}"
  scope      = "${data.azurerm_subscription.current.id}"
  lock_level = "CanNotDelete"
  notes      = "${data.azurerm_subscription.current.display_name} subscription can not be deleted"
}

#Azure Policy Assignments
resource "azurerm_policy_assignment" "itds_subs_tag-plcy-asgn-env" {
  name                 = "${var.subs_tag_plcy_asgn_env_nm}"
  scope                = "${data.azurerm_subscription.current.id}"
  #apply tag and its default value policy definition
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/2a0e14a6-b0a6-4fab-991a-187a4f81c498"
  display_name         = "Apply Environment tag and ${var.env_name} as its default value"
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
  name                 = "${var.subs_tag_plcy_asgn_grp_nm}"
  scope                = "${data.azurerm_subscription.current.id}"
  #apply tag and its default value policy definition
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/2a0e14a6-b0a6-4fab-991a-187a4f81c498"
  display_name         = "Apply Environment tag and ${var.env_group} as its default value"
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
  name                 = "${var.subs_tag_plcy_asgn_admins_nm}"
  scope                = "${data.azurerm_subscription.current.id}"
  #apply tag and its default value policy definition
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/2a0e14a6-b0a6-4fab-991a-187a4f81c498"
  display_name         = "Apply Environment tag and ${var.env_admins} as its default value"
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
  name                 = "${var.subs_tag_plcy_asgn_allwd_loc_nm}"
  scope                = "${data.azurerm_subscription.current.id}"
  #apply tag and its default value policy definition
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c"
  display_name         = "Restrict region for all resources to ${var.env_location}"
  parameters = <<PARAMETERS
  {
    "allowedLocations": {
      "value": [ "${var.env_location}" ]
    }
  }
  PARAMETERS
}

resource "azurerm_resource_group" "itds_subs_rg" {
  name     = "${var.subs_rg_nm}"
  location = "${var.env_location}"
}
