variable "rg_prefix" {
  default = ""
  description = "The generic prefix for resoruces in this project"
  type =string
}

variable "tags" {
  default =  {
    project = "example"
  }
  description ="The generic tags for this project that go on all resources"
  type = map(string)

}

variable "env_tags" {
  default = {}
  description = "Environment specific tags"
  type = map(string)
}

variable "state_container_name" {
  default = ""
  description = "Used by the boostrap shell script but provide here incase it is needed, in the output by default"
  type = string
}

variable "state_key" {
  default = ""
  description = "Used by the bootstrap shell script but provided here incase it is needed, in the output by default"
  type = string
}
