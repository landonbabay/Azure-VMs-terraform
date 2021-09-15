variable "location" {
  type    = string
  default = "eastus"
}
variable "resource_group_name" {
  type    = string
  default = "cloud-rg-devenvironment"
}
variable "virtual_machine_name" {
  type    = string
  default = "cloud-vm-eastus"
}
variable "virtual_network_name" {
  type    = string
  default = "cloud-vnet-eastus"
}
variable "nsg_name" {
  type    = string
  default = "cloud-nsg-eastus"
}
variable "subnet_name" {
  type = string
  default = "cloud-subnet-eastus"
}
variable "public_ip_name" {
  type = string
  default = "cloud-pubip-eastus"
}
variable "netint_name" {
  type = string
  default = "cloud-netint-eastus"
}
variable "vm_name" {
    type = string
    default = "cloud-vm-eastus"
  
}