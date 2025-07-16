resource "azurerm_resource_group" "terra" {
  name     = "terra"
  location = "Central US"
}
resource "azurerm_virtual_network" "terra_vnet" {
    name                = "terra-vnet"
    address_space       = ["10.0.0.0/16"]
    location            = azurerm_resource_group.terra.location
    resource_group_name = azurerm_resource_group.terra.name
}
 
resource "azurerm_subnet" "subnet1" {
    name                 = "subnet1"
    resource_group_name  = azurerm_resource_group.terra.name
    virtual_network_name = azurerm_virtual_network.terra_vnet.name
    address_prefixes     = ["10.0.1.0/24"]
}
resource "azurerm_network_interface" "terra_nic" {
    name                = "terra-nic"
    location            = azurerm_resource_group.terra.location
    resource_group_name = azurerm_resource_group.terra.name

    ip_configuration {
        name                          = "internal"
        subnet_id                     = azurerm_subnet.subnet1.id
        private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_windows_virtual_machine" "terra_vm" {
    name                = "terra-vm"
    resource_group_name = azurerm_resource_group.terra.name
    location            = azurerm_resource_group.terra.location
    size                = "Standard_DS1_v2"
    admin_username      = "azureuser"
    admin_password      = "P@ssw0rd1234"
    network_interface_ids = [
        azurerm_network_interface.terra_nic.id,
    ]
    os_disk {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
        name                 = "terra-osdisk"
    }
    source_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2019-Datacenter"
        version   = "latest"
    }
}
