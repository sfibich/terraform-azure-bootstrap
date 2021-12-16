#####################
#Bootstrap Variables# 
#####################
state_container_name = "terraform-state"
state_key = "terraform.tfstate.prod.example-rg"
 

##################################################
#Regular Terraform Environment Specific Variables#
##################################################
rg_prefix = "prod"
env_tags = {
  env="production"
  }
