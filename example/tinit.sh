#!/bin/bash
function test() {

	terraform init --backend-config='storage_account_name=x63249403618806terraform' --backend-config='key=terraform.tfstate.dev.example-rg' --backend-config='container_name=terraform-state' --reconfigure
}

test
