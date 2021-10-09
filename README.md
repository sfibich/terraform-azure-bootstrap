# terraform-azure-bootstrap: 
### Enterprise-grade Terraform/Azure backend built for the individual 

![terraform-azure-bootstrap](terraform-azure-boostrap.png)

## Intro 
The terraform-azure-boostrap project provides an enterprise-ready backend using Azure resources.  Using the terraform-azure-bootstrap, move your Terraform state files to Azure Storage and use an App Registration Client Id and Client Secret for authorization to Azure.  This allows you to decouple the permissions from your account to that of the App Registration.  It also allows you to share state files across your organization with other developers or CICD pipelines.  Lastly, it allows you to release the same terraform code to different environments without overwriting state files and without modifying the terraform code or having some sort of pre-execution replacement script run.

## Requirements

- AZ Cli
- An Azure Account
- Bash Shell

## Contents

- [Intro](#intro)
- [Requirements](#requirements)
- [Inital Setup](#inital-setup)
- [Bootstrapping](#bootstrapping)
- [Scripts](#scripts)

## Initial Setup 
(once per environment) 

```{r, engine='sh', count_lines}
az account login
cd /setup
./ConfigureAzureForSecureTerraformAccess.sh
source ./LoadAzureTerraformSecretsToEnvVars.sh
cd ../simpleTestResourceGroup
terraform init
terraform plan
```

## Bootstrapping
(per project/environment switch)

```
source ./LoadAzureTerrformSecretsToEnvVars.sh
terraform plan
```

## Scripts

### ConfigureAzureForSecureTerraformAccess.sh

The script creates a resource group, a key vault, a storage account, and an SPN.  It loads the client id, client secret, tenant id, subscription id, and storage account access key into the key vault. Next, the script grants the current user ownership over the key vault. Finally, it uses the current subscription the user is logged into to create the resources.

### LoadAzureTerraformSecretsToEnvVars.sh

This script loads the information in the Azure Key Vault to session variables so that Terraform can use them to execute scripts without 
having to provide the information manually.  It also sets up the access key to a storage account so it can be used to manage terraform state.
 
### bareBonesTools.sh

Bash shell script to install tools necessary to run the other two scripts as well as Terrafrom
