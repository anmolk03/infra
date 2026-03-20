variable "subscription_id" {
  type = string
}

# 1️⃣ Mandatory Tags: 'Business Unit' and 'Cost Center'
resource "azurerm_policy_assignment" "mandatory_tags" {
  name                 = "mandatory-tags-assignment"
  scope                = "/subscriptions/${var.subscription_id}"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/4f9dc7db-30c1-420c-b61a-e1d640128d26" # Add a tag to resources

  parameters = jsonencode({
    tagName  = "Business Unit"
    tagValue = "[DoNotChange]"   # Value can be anything, will be assigned if missing
  })

  # To enforce second tag, you can create another assignment:
  depends_on = []
}

resource "azurerm_policy_assignment" "mandatory_tags_costcenter" {
  name                 = "mandatory-tags-costcenter-assignment"
  scope                = "/subscriptions/${var.subscription_id}"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/4f9dc7db-30c1-420c-b61a-e1d640128d26" # Add a tag to resources

  parameters = jsonencode({
    tagName  = "Cost Center"
    tagValue = "[DoNotChange]"
  })
}

# 2️⃣ No Public IPs on NIC
resource "azurerm_policy_assignment" "no_public_ip" {
  name                 = "no-public-ip-assignment"
  scope                = "/subscriptions/${var.subscription_id}"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/83a86a26-fd1f-447c-b59d-e51f44264114" # Network interfaces should not have public IPs
  description          = "Deny public IPs on NICs"
  enforce              = true
}

# 3️⃣ Allowed Locations: Central, South, West India
resource "azurerm_policy_assignment" "allowed_locations" {
  name                 = "allowed-locations-assignment"
  scope                = "/subscriptions/${var.subscription_id}"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c" # Allowed locations

  parameters = jsonencode({
    listOfAllowedLocations = [
      "centralindia",
      "southindia",
      "westindia"
    ]
  })

  description = "Restrict resource deployment to Central, South, West India"
  enforce     = true
}
















# Data source to get the current subscription
data "azurerm_subscription" "current" {}

# 1. Location Restriction
resource "azurerm_subscription_policy_assignment" "location_restriction" {
  name                 = "limit-locations-india"
  subscription_id      = data.azurerm_subscription.current.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975a4c"
  display_name         = "Restrict locations to India"

  parameters = jsonencode({
    listOfAllowedLocations = {
      value = ["centralindia", "southindia", "westindia"]
    }
  })
}

# 2. Deny Public IPs on NICs
resource "azurerm_subscription_policy_assignment" "no_public_ips" {
  name                 = "deny-public-ips-nic"
  subscription_id      = data.azurerm_subscription.current.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/83a86538-4f51-4681-807b-83956101c775"
  display_name         = "Deny Public IPs on NICs"
}

# 3. Mandatory Tags (Example for Business Unit)
resource "azurerm_subscription_policy_assignment" "mandatory_tag_bu" {
  name                 = "require-bu-tag"
  subscription_id      = data.azurerm_subscription.current.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/1e30110a-5ceb-460c-80fd-bf4c90d09e1d"
  display_name         = "Require Business Unit Tag"

  parameters = jsonencode({
    tagName = { value = "Business Unit" }
  })
}
