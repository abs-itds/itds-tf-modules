resource "azurerm_role_definition" "itds-dta-eng-rl" {
  name        = "${var.env_prefix}-dta-eng-rl"
  scope       = "${data.azurerm_subscription.current.id}"
  description = "ITDS Data Engineer role"

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    "${data.azurerm_subscription.current.id}"
  ]
}