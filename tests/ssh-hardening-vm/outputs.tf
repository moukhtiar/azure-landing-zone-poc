output "test_vm_name" {
  description = "Name of the disposable SSH hardening test VM."
  value       = azurerm_linux_virtual_machine.test.name
}

output "test_vm_private_ip" {
  description = "Private IP address allocated to the test VM."
  value       = azurerm_network_interface.test.private_ip_address
}

output "test_nic_name" {
  description = "Name of the disposable test VM network interface."
  value       = azurerm_network_interface.test.name
}
