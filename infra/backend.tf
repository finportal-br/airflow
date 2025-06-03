terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "airflowtfstate"
    container_name       = "tfstate"
    key                  = "airflow/terraform.tfstate"
  }
}
