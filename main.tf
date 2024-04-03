resource "azurerm_resource_group" "this" {
  name     = "${local.prefix_name}-${local.config.resource_group.name}"
  location = local.config.resource_group.location
}

resource "azurerm_cognitive_account" "this" {
  name                = "${local.prefix_name}-${local.config.azurerm_content_safety_service.name}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  kind                = "ContentSafety"

  sku_name = "F0"
}
