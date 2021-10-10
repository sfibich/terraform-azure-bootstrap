#!/bin/bash

#############################################################################################################################
#DESCRIPTION																												#
#	Loads Azure Key Vault secrets into Terraform environment variables for the current bash session.						#
#																															#
#    The following steps are automated:																						#
#    - Identifies the Azure Key Vault matching a search string (default: 'terraform-kv').									#
#    - Retrieves the Terraform secrets from Azure Key Vault.																#
#    - Loads the Terraform secrets into these environment variables for the current bash session:							#
#        - ARM_SUBSCRIPTION_ID																								#
#        - ARM_CLIENT_ID																									#
#        - ARM_CLIENT_SECRET																								#
#        - ARM_TENANT_ID																									#
#        - ARM_ACCESS_KEY																									#
#																															#
#EXAMPLE																													#
#    source ./LoadAzureTerraformSecretsToEnvVars.sh																			#
#                                                                             												#	
#    Loads Azure Key Vault secrets into Terraform environment variables for the current bash session						#
#																															#
#NOTES																														#
#    Assumptions:																											#
#    - Az Cli install																										#
#	 - You are inside a bash session																						#
#    - You are already logged into Azure before running this script (eg. az account login)									#
#																															#
#    Author:  SFibich																										#	
#    GitHub:  https://github.com/sfibich																					#
#																															#
#    This script was modeled after Adam Rush's script LoadAzureTerraformSecretsToEnvVars.ps1 https://github.com/adamrushuk.	#
#																															#
#############################################################################################################################
SKIP=FALSE
OPTIND=1
while getopts :m:f:k:r:s: flag
do
    case "${flag}" in
		f) ENV_FILE=${OPTARG};;
        k) USER_KEY_VAULT_PATTERN=${OPTARG};;
        r) USER_RESOURCE_GROUP=${OPTARG};;
        s) USER_SUBSCRIPTION=${OPTARG};;
		m) SKIP=${OPTARG};;
		?) SKIP=TRUE 
			echo "help: switches -f ENV_FILE -k USER_KEY_VAULT_PATTERN -r USER_RESOURCE_GROUP -s USER_SUBSCRIPTION" ;;
    esac
done


function read_env_file() {
	echo "ENV FILE: $ENV_FILE"
	a=$(grep state_container_name $ENV_FILE)
	b=$(echo $a | tr -d "=")
	c=${b#state_container_name}
	d=$(echo $c | tr -d '"')
	e=${d##*( )};
	STATE_CONTAINER_NAME=$e

	f=$(grep state_key $ENV_FILE)
	g=$(echo $f | tr -d "=")
	h=${g#state_container_name}
	i=$(echo $h | tr -d '"')
	j=${i##*( )};
	STATE_KEY=$j
	
	echo "STATE_CONTAINER_NAME: $STATE_CONTAINER_NAME"
	echo "STATE_KEY: $STATE_KEY"
}

function set_core_variables() {

if [ -z "$USER_KEY_VAULT_PATTERN" ]
	then
		KEY_VAULT_NAME_PATTERN=terraform-kv
		echo "Using Default KEY_VAULT_NAME_PATTERN:$KEY_VAULT_NAME_PATTERN"
	else
		KEY_VAULT_NAME_PATTERN=$USER_KEY_VAULT_PATTERN
		echo "Using input KEY_VAULT_NAME_PATTERN: $KEY_VAULT_NAME_PATTERN"
fi

if [ -z "$USER_RESOURCE_GROUP" ]
	then
		TERRAFORM_RESOURCE_GROUP=terraform-mgmt-rg
		echo "Using Default TERRAFORM_RESORUCE_GROUP:$TERRAFORM_RESOURCE_GROUP"
	else
		TERRAFORM_RESOURCE_GROUP=$USER_RESOURCE_GROUP
		echo "Using input TERRAFORM_RESOURCE_GROUP:$TERRAFORM_RESOURCE_GROUP"
fi


}

function get_backend_values() {

	BACKEND_STORAGE_ACCOUNT=$(az storage account list --resource-group $TERRAFORM_RESOURCE_GROUP --query "[?contains(@.name, 'terraform')==\`true\`].name" --output tsv)
	BACKEND_CONTAINER=terraform-state
}


function get_keyvault_values() {

#####################
#Check Azure login	#
#####################
echo "Checking for an active Azure login..."

CURRENT_SUBSCRIPTION_ID=$(az account list --query "[?isDefault].id" --output tsv)

if [ -z "$CURRENT_SUBSCRIPTION_ID" ]
	then 
		printf '%s\n' "ERROR! Not logged in to Azure. Run az account login" >&2
#		exit 1
	else
		echo "SUCCESS!"
fi

#####################
#Get Azure Key Vault#
#####################
echo "Searching for Terraform KeyVault..."
KEY_VAULT_NAME=$(az keyvault list --resource-group $TERRAFORM_RESOURCE_GROUP --query "[?contains(name,'$KEY_VAULT_NAME_PATTERN')].name" --output tsv)

if [ -z "$KEY_VAULT_NAME" ]
	then
		printf '%s\n' "ERROR! No Azure Key Vault with name pattern like $KEY_VAULT_NAME_PATTERN" >&2
#		exit 1
	else
		echo "SUCCESS!"
fi

#############################
#Get Azure KeyVault Secrets	#
#############################
echo "Loading ARM_SUBSCRIPTION_ID..."
ARM_SUBSCRIPTION_ID=$(az keyvault secret show --vault-name $KEY_VAULT_NAME --name ARM-SUBSCRIPTION-ID --query "value" --output tsv)
if [ -z "$ARM_SUBSCRIPTION_ID" ]
	then 
		printf '%s\n' "FAILURE! Azure Key Vault missing secret ARM-SUBSCRIPITON-ID" >&2
	else
		echo "SUCCESS!"
fi

echo "Loading ARM_CLIENT_ID..."
ARM_CLIENT_ID=$(az keyvault secret show --vault-name $KEY_VAULT_NAME --name ARM-CLIENT-ID --query "value" --output tsv)
if [ -z "$ARM_CLIENT_ID" ]
	then 
		printf '%s\n' "FAILURE! Azure Key Vault missing secret ARM-CLIENT-ID" >&2
	else
		echo "SUCCESS!"
fi

echo "Loading ARM_CLIENT_SECERT"
ARM_CLIENT_SECRET=$(az keyvault secret show --vault-name $KEY_VAULT_NAME --name ARM-CLIENT-SECRET --query "value" --output tsv)
if [ -z "$ARM_CLIENT_SECRET" ]
	then 
		printf '%s\n' "FAILURE! Azure Key Vault missing secret ARM-CLIENT-SECRET" >&2
	else
		echo "SUCCESS!"
fi

echo "Loading ARM_TENANT_ID..."
ARM_TENANT_ID=$(az keyvault secret show --vault-name $KEY_VAULT_NAME --name ARM-TENANT-ID --query "value" --output tsv)
if [ -z "$ARM_TENANT_ID" ]
	then 
		printf '%s\n' "FAILURE! Azure Key Vault missing secret ARM-TENANT-ID" >&2
	else
		echo "SUCCESS!"
fi

echo "Loading ARM_ACCESS_KEY..."
ARM_ACCESS_KEY=$(az keyvault secret show --vault-name $KEY_VAULT_NAME --name ARM-ACCESS-KEY --query "value" --output tsv)
if [ -z "$ARM_ACCESS_KEY" ]
	then 
		printf '%s\n' "FAILURE! Azure Key Vault missing secret ARM-ACCESS_KEY" >&2
	else
		echo "SUCCESS!"
fi

echo "Loading TF_VAR_target_subscription_id.."
if [ -z "$USER_SUBSCRIPTION" ]
	then
		TF_VAR_target_subscription_id=$ARM_SUBSCRIPTION_ID
		echo "Used ARM_SUBSCRIPTION_ID from key vault...SUCCESS"
	else
		TF_VAR_target_subscription_id=$USER_SUBSCRIPTION
		echo "Used value passed w/script...SUCCESS"
fi
}

function output_info() {
	echo "************************************************************************"
	echo "                              SPN VALUES"
	echo "************************************************************************"
	echo "ARM_SUBSCRIPTION_ID: $ARM_SUBSCRIPTION_ID"
	echo "ARM_CLIENT_ID:       $ARM_CLIENT_ID"
	echo "ARM_CLIENT_SECRET:   HIDDEN!"
	echo "ARM_TENANT_ID:       $ARM_TENANT_ID"
	echo "ARM_ACCESS_KEY:      $ARM_ACCESS_KEY"
	echo "************************************************************************"
	echo ""
	echo "************************************************************************"
	echo "                              BACKEND VALUES"
	echo "************************************************************************"
	echo "TF_VAR_target_subscription_id:$TF_VAR_target_subscription_id"
	echo "TERRAFORM_RESOURCE_GROUP:     $TERRAFORM_RESOURCE_GROUP"
	echo "BACKEND_STORAGE_ACCOUNT:      $BACKEND_STORAGE_ACCOUNT"
	echo "BACKEND_CONTAINER:            $BACKEND_CONTAINER"
	echo "************************************************************************"
	echo ""
	echo "************************************************************************"
	echo "                              TF VALUES for EXPORT"
	echo "************************************************************************"
	echo "TF_VAR_target_subscription_id: $TF_VAR_target_subscription_id"
	export TF_VAR_target_subscription_id=$TF_VAR_target_subscription_id
	export ARM_CLIENT_ID=$ARM_CLIENT_ID
	export ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET
	export ARM_TENANT_ID=$ARM_TENANT_ID
	export ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID
	export ARM_ACCESS_KEY=$ARM_ACCESS_KEY
}

function terraform_init() {

	echo "Running: terraform init --backend-config='storage_account_name=$BACKEND_STORAGE_ACCOUNT' --backend-config='key=$STATE_KEY' --backend-config='container_name=$STATE_CONTAINER_NAME'"

	terraform init --backend-config='storage_account_name=$BACKEND_STORAGE_ACCOUNT' --backend-config='key=$STATE_KEY' --backend-config='container_name=$STATE_CONTAINER_NAME'

}
#####################
#		MAIN		#
#####################

if [[ $SKIP == "FALSE" ]]
	then
		set_core_variables
		get_backend_values
		get_keyvault_values
		read_env_file
		output_info
		terraform_init

		echo "FINISHED!"

	else
		read_env_file
		echo ""
fi
