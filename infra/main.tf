provider "azurerm" {
  features {}

  subscription_id = "7fcedad6-03d1-4afa-8a82-09dc2a4c1fad"
}

variable "redeploy_tag" {
  type    = string
  default = "dev"
}

resource "azurerm_resource_group" "rg" {
  name     = "airflow-rg"
  location = "eastus"
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


variable "acr_password" {
  type = string
}


resource "azurerm_container_app" "web" {
  name                         = "airflow-web"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = azurerm_resource_group.rg.name

  revision_mode = "Single"

  # 🔐 Referência ao ACR manual

  registry {
    server               = "airflowacr1234.azurecr.io"
    username             = "airflowacr1234"
    password_secret_name = "acr-password"
  }

  secret {
    name  = "acr-password"
    value = var.acr_password
  }

  template {
    revision_suffix = var.redeploy_tag

    container {
      name    = "airflow"
      image   = "airflowacr1234.azurecr.io/airflow:latest"
      cpu     = 0.5
      memory  = "1.0Gi"
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

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}

output "url" {
  value = azurerm_container_app.web.ingress[0].fqdn
}
