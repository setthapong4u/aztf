# main.tf

# Generate a random string to use as a password for the VM
resource "random_string" "password" {
  length      = 16
  special     = false
  min_lower   = 1
  min_numeric = 1
  min_upper   = 1
}

# Resource Group where all resources will be created
resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = var.location
}

# Virtual Network (VNet) that will contain the subnet for the VM
resource "azurerm_virtual_network" "vnet" {
  name                = "example-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
}

# Subnet inside the VNet
resource "azurerm_subnet" "subnet" {
  name                 = "example-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Network Security Group (NSG)
resource "azurerm_network_security_group" "nsg" {
  name                = "example-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name

  security_rule {
    name                       = "allow_ssh"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_http"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Network Interface to connect the VM to the network
resource "azurerm_network_interface" "ni_linux" {
  name                = "example-nic-linux"
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Associate the Network Interface with the Network Security Group
resource "azurerm_network_interface_security_group_association" "ni_nsg_association" {
  network_interface_id      = azurerm_network_interface.ni_linux.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Linux Virtual Machine configuration
resource "azurerm_linux_virtual_machine" "linux_machine" {
  name                            = "terragoat-linux"
  location                        = var.location
  resource_group_name             = azurerm_resource_group.example.name
  network_interface_ids           = [azurerm_network_interface.ni_linux.id]
  size                            = "Standard_F2"
  admin_username                  = "terragoat-linux"
  admin_password                  = random_string.password.result
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Use Ubuntu 18.04 as the operating system
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  tags = {
    terragoat   = true
    environment = var.environment
  }
}

