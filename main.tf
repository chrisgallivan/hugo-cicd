#terraform remote state
terraform {
     required_providers {
        azurerm = {
           source = "hashicorp/azurerm"
        }
    }
    backend "remote" {
	organization = "KATA-FRIDAYS"
	workspaces {
		name = "gh-actions-demo"
	}
   }
}

provider "azurerm" {
   client_id = var.client_id
   client_secret = var.client_secret
   subscription_id= var.subscription_id
   tenant_id= var.tenant_id
}

resource "azurerm_resource_group" "example" {
  name     = "hugo-resources"
  location ="eastus"
}

resource "azurerm_app_service_plan" "example" {
  name                = "hugo-asp"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "example" {
  name                = "hugo-appservice"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  app_service_plan_id = azurerm_app_service_plan.example.id

  site_config {
    app_command_line = ""
    linux_fx_version = "DOCKER|chrisgallivan/hugo-cicd:latest"
    always_on        = "true"
  }

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = false
    "DOCKER_REGISTRY_SERVER_URL"          = "https://index.docker.io"
    "DOCKER_ENABLE_CI"                    = true
   
  }
}