#####################
#Bootstrap Variables# 
#####################
state_container_name = "terraform-state"
state_key = "terraform.tfstate.dev.example-rg"
 

##################################################
#Regular Terraform Environment Specific Variables#
##################################################
rg_prefix = "dev"
env_tags = {
  env="development"
  }
