//this is a demo, this does not take into account state of your terraform deployments
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.75.0"
    }
  }
}
provider "azurerm" {
  features {}
}
//creating the resource group that will hold our development environment
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}
//creating the virtual network and subnet 
resource "azurerm_virtual_network" "development-vnet" {
  name = "${var.virtual_network_name}-dev"
  location = var.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space = ["192.168.0.0/16"]

}
resource "azurerm_subnet" "development-subnet" {
    name = "${var.subnet_name}-dev"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.development-vnet.name
    address_prefixes = ["192.168.2.0/24"]
}
resource "azurerm_network_security_group" "development-nsg" {
  name = "${var.nsg_name}-dev"
  location = var.location
  resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_network_security_rule" "development-nsg-rule" {
    name = "ssh-rule"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "TCP"
    source_port_range = "*"
    destination_port_range = 22
    //for more security, you should put in your public IP address
    source_address_prefix = "*"
    destination_address_prefix = "VirtualNetwork"
    resource_group_name = azurerm_resource_group.rg.name
    network_security_group_name = azurerm_network_security_group.development-nsg.name
}
//associate the nsg at the subnet level
resource "azurerm_subnet_network_security_group_association" "development-nsg-association" {
  subnet_id = azurerm_subnet.development-subnet.id
  network_security_group_id = azurerm_network_security_group.development-nsg.id
}
//creating the public IP addresses that will be linked to our VM network interfaces
resource "azurerm_public_ip" "development-pupip1" {
  name = "${var.public_ip_name}-dev1"
  resource_group_name = azurerm_resource_group.rg.name
  location = var.location
  allocation_method = "Dynamic"
}
resource "azurerm_public_ip" "development-pupip2" {
  name = "${var.public_ip_name}-dev2"
  resource_group_name = azurerm_resource_group.rg.name
  location = var.location
  allocation_method = "Dynamic"
}
//creating the network interafaces that will be associated with the public IP addresses
resource "azurerm_network_interface" "development-netint1" {
  name = "${var.netint_name}-dev1"
  location = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name = "ipconfig1"
    subnet_id = azurerm_subnet.development-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.development-pupip1.id

  }
}
resource "azurerm_network_interface" "development-netint2" {
  name = "${var.netint_name}-dev2"
  location = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name = "ipconfig1"
    subnet_id = azurerm_subnet.development-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.development-pupip2.id
    
  }
}
//creating the two virtual machines. One Linux and One Windows
resource "azurerm_virtual_machine" "development-vm1" {
  name = "${var.vm_name}-vm1"
  location = var.location
  resource_group_name = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.development-netint1.id]
  vm_size = "Standard_B2s"

  storage_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "18.04-LTS"
    version = "latest"
  }
  storage_os_disk {
    name = "linuxstoragedisk1"
    caching = "ReadWrite"
    create_option = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
      //it is not a secure practice to store username/passwords in terraform files but this is for dev purposes DO NOT LEAVE THIS RUNNING IN PRODUCTION
    computer_name= "linuxDev"
    admin_username = "terraformadmin"
    admin_password = "Terraform1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = "false"
  }
}
resource "azurerm_virtual_machine" "development-vm2" {
  name = "${var.vm_name}-vm2"
  location = var.location
  resource_group_name = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.development-netint2.id]
  vm_size = "Standard_B2s"

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer = "WindowsServer"
    sku = "2019-Datacenter"
    version = "latest"
  }
  storage_os_disk {
    name = "windowsstoragedisk1"
    caching = "ReadWrite"
    create_option = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
      //it is not a secure practice to store username/passwords in terraform files but this is for dev purposes DO NOT LEAVE THIS RUNNING IN PRODUCTION
    computer_name= "windowsDev"
    admin_username = "terraformadmin"
    admin_password = "Terraform1234!"
  }
  os_profile_windows_config {
    enable_automatic_upgrades = "false"
  }
 
}


