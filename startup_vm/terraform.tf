### Not for use in plan
### This TF template is only used to create the CS Startup VM

variable "prefix" {
  default = "cloudshare"
}

# Linux Machine

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            = "${data.azurerm_resource_group.main.location}"
  resource_group_name = "${data.azurerm_resource_group.main.name}"
  # network_security_group_id = "${azurerm_network_security_group.vm-nsg.id}"

  ip_configuration {
    name                          = "${var.prefix}-ip"
    subnet_id                     = "${azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_public_ip" "public-ip" {
  name                = "${var.prefix}-pub-ip"
  location            = "${data.azurerm_resource_group.main.location}"
  resource_group_name = "${data.azurerm_resource_group.main.name}"
  allocation_method   = "Static"
}

resource "azurerm_network_security_group" "vm-nsg" {
  name                = "${var.prefix}-nsg"
  location            = "${data.azurerm_resource_group.main.location}"
  resource_group_name = "${data.azurerm_resource_group.main.name}"
  security_rule {
    name                       = "allow-ssh"
    description                = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "nsg-association" {
  network_interface_id      = "${azurerm_network_interface.main.id}"
  network_security_group_id = "${azurerm_network_security_group.vm-nsg.id}"
}

resource "azurerm_linux_virtual_machine" "main" {
  name                  = "Azure-ubuntu-18"
  location              = "${data.azurerm_resource_group.main.location}"

  resource_group_name   = "${data.azurerm_resource_group.main.name}"
  
  admin_username = "azadmin"
  disable_password_authentication = false
  admin_password = "Passw0rd1234!"
 
  
  network_interface_ids = [
      "${azurerm_network_interface.main.id}"
      ]
  size               = "Standard_B1ls"
  
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }
  
  tags = {
    environment = "staging"
  }
}

# End of Linux Machine
  
resource "azurerm_virtual_network" "vnet" {   //Here defined the virtual network
  name                = "${var.prefix}-network"  
  address_space       = ["10.0.0.0/16"]  
  location            = "${data.azurerm_resource_group.main.location}"
  resource_group_name = "${data.azurerm_resource_group.main.name}"
}  
  
resource "azurerm_subnet" "subnet" {   //Here defined subnet
  name                 = "${var.prefix}-subnet"  
  resource_group_name  = "${data.azurerm_resource_group.main.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefixes       = ["10.0.2.0/24"]  
}


resource "azurerm_virtual_machine_extension" "myterraformvm" {
  name = "falcon-sensor-install-linux"
  virtual_machine_id = azurerm_linux_virtual_machine.main.id
  publisher = "Microsoft.Azure.Extensions"
  type = "CustomScript"
  type_handler_version = "2.0"
  settings = <<SETTINGS
  { 
    "fileUris": [ 
          "https://raw.githubusercontent.com/mccbryan3/csdemo_azure_aks/main/scripts/startup.sh"
        ],
    "commandToExecute": "/bin/bash startup.sh"
  }
  SETTINGS

  tags = {
    environment = "Development"
  }
}