provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "airflow-rg"
  location = "eastus"
}

resource "azurerm_container_registry" "acr" {
  name                = "airflowacr1234"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

resource "azurerm_log_analytics_workspace" "log" {
  name                = "airflow-logs"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "env" {
  name                       = "airflow-env"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log.id
}

resource "azurerm_container_app" "web" {
  name                         = "airflow-web"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location

  revision_mode = "Single"
  variable "redeploy_tag" {
    type    = string
    default = "dev"
  }

  template {
    revision_suffix = var.redeploy_tag
    container {
      name   = "airflow"
      image  = "${azurerm_container_registry.acr.login_server}/airflow:latest"
      cpu    = 0.5
      memory = "1.0Gi"
      command = ["airflow", "webserver"]
      env {
        name  = "AIRFLOW__CORE__LOAD_EXAMPLES"
        value = "false"
      }
    }
  }

  ingress {
    external_enabled = true
    target_port      = 8080
    transport        = "auto"
  }

  registry {
    server   = azurerm_container_registry.acr.login_server
    username = azurerm_container_registry.acr.admin_username
    password = azurerm_container_registry.acr.admin_password
  }
}

output "url" {
  value = azurerm_container_app.web.ingress[0].fqdn
}