terraform {
  backend "azurerm" {}
}
data "azurerm_subscription" "current" {}

resource "azurerm_management_lock" "${var.subscription_name}-subs-lk" {
  name       = "${var.subscription_name}-subscription-lock"
  scope      = "${data.azurerm_subscription.current.id}"
  lock_level = "CanNotDelete"
  notes      = "${var.subscription_name} subscription can not be deleted"
}

#Azure Policy Assignments
resource "azurerm_policy_assignment" "tag-plcy-asgn-env" {
  name                 = "${var.env_prefix}-tag-plcy-asgn-env"
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

resource "azurerm_policy_assignment" "tag-plcy-asgn-grp" {
  name                 = "${var.env_prefix}-tag-plcy-asgn-grp"
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

resource "azurerm_policy_assignment" "tag-plcy-asgn-admins" {
  name                 = "${var.env_prefix}-tag-plcy-asgn-admins"
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


resource "azurerm_policy_assignment" "tag-plcy-asgn-allwd-loc" {
  name                 = "${var.env_prefix}-tag-plcy-asgn-allwd-loc"
  scope                = "${data.azurerm_subscription.current.id}"
  #apply tag and its default value policy definition
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/2a0e14a6-b0a6-4fab-991a-187a4f81c498"
  display_name         = "Restrict region for all resources to ${var.env_location}"
  parameters = <<PARAMETERS
  {
    "allowedLocations": {
      "value": [ "${var.env_location}" ]
    }
  }
  PARAMETERS
}

resource "azurerm_resource_group" "${var.env_prefix}-rg" {
  name     = "${var.env_prefix}-rg"
  location = "${var.env_location}"
}
