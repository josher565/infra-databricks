output "databricks_host" {
  value = "https://${azurerm_databricks_workspace.ws.workspace_url}/"
}