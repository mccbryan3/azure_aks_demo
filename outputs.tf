output "vm_public_ip" {
  depends_on = [
    azurerm_public_ip.public-ip
  ]
  value = azurerm_linux_virtual_machine.linux.public_ip_address
}

output "lumos_deployed" {
  value = var.deploy_lumos
}

output "admin_vm_password" {
  value = "${var.vmname}!${var.suffix}"
}