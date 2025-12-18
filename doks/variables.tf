variable "name" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_uuid" {
  type    = string
  default = null
}

variable "doks_version" {
  type    = string
  default = null
}

variable "node_slug" {
  type    = string
  default = null
}

variable "ha" {
  type    = bool
  default = false
}

variable "tags" {
  type    = list(string)
  default = ["jkeegan"]
}

variable "routing_agent" {
  type    = bool
  default = true
}

variable "registry_integration" {
  type    = bool
  default = true
}

variable "destroy_all_associated_resources" {
  type    = bool
  default = true
}
