terraform {
  required_providers {
    azurerm = "~> 2.33"
    databricks = {
      source  = "databrickslabs/databricks"
      version = "0.3.1"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "databricks_user" "josh" {
  user_name    = "josh.robinson@gmail.com"
  display_name = "Josh"
}

resource "azurerm_resource_group" "this" {
  name     = var.rg
  location = var.location
  tags     = var.tags
}

resource "azurerm_databricks_workspace" "ws" {
  name                        = "${var.prefix}workspace"
  resource_group_name         = azurerm_resource_group.this.name
  location                    = azurerm_resource_group.this.location
  sku                         = "premium"
  managed_resource_group_name = "${var.prefix}workspace-rg"
  tags                        = var.tags
}

provider "databricks" {
  azure_workspace_resource_id = azurerm_databricks_workspace.ws.id
}


//secret storage, key and user access
resource "databricks_secret_scope" "this" {
  name = "demo-secret"
}

resource "databricks_token" "pat" {
  comment          = "Created from ${abspath(path.module)}"
  lifetime_seconds = 3600
}

resource "databricks_secret" "token" {
  string_value = databricks_token.pat.token_value
  scope        = databricks_secret_scope.this.name
  key          = "token"
}

