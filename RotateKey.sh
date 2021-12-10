#!/bin/bash
#############################################################################################################################
#DESCRIPTION
#    Resets the ARM_ACCESS_KEY value in the Key Vault.
#
#EXAMPLE
#    az account login
#    ./RotateKey.sh
#
#NOTES
#    Assumptions:
#    - az cli is installed
#    - You are already logged into Azure before running this script (eg.az account login)
#
#    Author:  sfibich
#    GitHub:  https://github.com/sfibich
#
#############################################################################################################################

#Exit on error
set -e

SERVICE_PRINCIPLE_NAME='terraform'
RESOURCE_GROUP_NAME='terraform-mgmt-rg'

KEY_VAULT_NAME=$(az keyvault list --resource-group terraform-mgmt-rg --query "[].name" --output tsv)
STORAGE_ACCOUNT_NAME=$(az storage account list --resource-group $RESOURCE_GROUP_NAME --query "[].name" --output tsv)
JSON_OUTPUT=$(az storage account keys renew --account-name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP_NAME --key secondary) 
#echo $JSON_OUTPUT
SEARCH_STRING='"keyName": "key2",'
FIRST_CUT=${JSON_OUTPUT#*$SEARCH_STRING}
#echo $FIRST_CUT
#ASSUMES KEY comes before VALUE...bad assumption but works
SEARCH_STRING_2='"value": "'
SECOND_CUT=${FIRST_CUT#*$SEARCH_STRING_2}
#echo $SECOND_CUT
SEARCH_STRING_3='"'
THIRD_CUT=${SECOND_CUT#*$SEARCH_STRING_3}
#echo $THIRD_CUT
LENGTH=$(( ${#SECOND_CUT} - ${#THIRD_CUT} - ${#SEARCH_STRING_3} ))
#echo $LENGTH
ARM_ACCESS_KEY=$(echo $SECOND_CUT | cut -c1-$LENGTH)

#############################
#Create KeyVault Secrets	#
#############################
echo "Updating KeyVault Secrets for Terraform:ARM-ACCESS-KEY"
az keyvault secret set --name ARM-ACCESS-KEY --value $ARM_ACCESS_KEY --vault-name $KEY_VAULT_NAME --output none


