# Configure the Azure provider
terraform {
  backend "azurerm" {
    container_name       = "terraform-state"
    key                  = "terraform.tfstate.example-rg"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.80.0"

    }
  }

  required_version = ">= 1.0.5"
}


