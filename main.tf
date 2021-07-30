# required for terraform
provider "azurerm" {
  features {}
}

# resource group
resource "azurerm_resource_group" "main" {
  name     = "bobby-web-project-rg"
  location = var.location
}

# availability set needed for creating multiple vms
resource "azurerm_availability_set" "main" {
  name                        = "${var.prefix}-as"
  location                    = var.location
  resource_group_name         = azurerm_resource_group.main.name
  platform_fault_domain_count = 2
  tags = {
    purpose = var.purpose
  }
}

# network security group
resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  security_rule {
    name                       = "DenyInternetIn"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "VirtualNetwork"
  }  
  security_rule {
    name                       = "AllowVnetIn"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }
  tags = {
    purpose = var.purpose
  }
}

# public ip
resource "azurerm_public_ip" "main" {
  name                = "${var.prefix}-pubIp"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  allocation_method   = "Static"
  tags = {
    purpose = var.purpose
  }
}

# load balancer
resource "azurerm_lb" "main" {
  name                = "${var.prefix}-lb"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  frontend_ip_configuration {
    name                 = "PubIP"
    public_ip_address_id = azurerm_public_ip.main.id
  }

  tags = {
    purpose = var.purpose
  }
}

# address pool
resource "azurerm_lb_backend_address_pool" "main" {
  resource_group_name = azurerm_resource_group.main.name
  loadbalancer_id     = azurerm_lb.main.id
  name                = "AddressPool"
}

# virtual network
resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-net"
  address_space       = ["10.0.0.0/22"]
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  tags = {
	purpose = var.purpose
  }
}

# subnet
resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
  # can't put tags on subnet?
  #tags = {
  #  purpose = var.purpose
  #}
}

# nic
resource "azurerm_network_interface" "main" {
  count = var.numVms
  name                = "${var.prefix}-${count.index}-nic"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
  tags = {
	purpose = var.purpose
  }
}

# pool
resource "azurerm_network_interface_backend_address_pool_association" "main" {
  count = var.numVms
  network_interface_id    = azurerm_network_interface.main[count.index].id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
}

# vm
resource "azurerm_linux_virtual_machine" "main" {
  count = var.numVms
  name                            = "${var.prefix}-${count.index}-vm"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = var.location
  size                            = "Standard_D2s_v3"
  admin_username                  = "bobby"
  admin_password                  = "Mander123"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.main[count.index].id,
  ]
  availability_set_id = azurerm_availability_set.main.id
  source_image_id = var.image
  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
  tags = {
	purpose = var.purpose
  }
}

# managed disk
resource "azurerm_managed_disk" "main" {
  name                 = "${var.prefix}-md"
  location             = var.location
  resource_group_name  = azurerm_resource_group.main.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "2"
  tags = {
    purpose = var.purpose
  }
}
