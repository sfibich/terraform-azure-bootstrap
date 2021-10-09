#!/bin/bash
#############################
# Target: Debian 10         #
#############################
sudo apt-get update -y 
sudo apt-get upgrade -y 

#############
# az client #
#############
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

############################
# Terraform                #
############################
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform
