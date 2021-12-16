#####################
#Bootstrap Variables# 
#####################
state_container_name = "terraform-state"
state_key = "terraform.tfstate.test.example-rg"
 

##################################################
#Regular Terraform Environment Specific Variables#
##################################################
rg_prefix = "test"
env_tags = {
  env="test"
  }
