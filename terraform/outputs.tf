output "vm_lan_ip" {
  description = "LAN address of the VM. Set FREEBOX_VM_HOST to this for Ansible."
  value       = var.lan_ip
}

output "vm_mac" {
  description = "MAC address of the VM."
  value       = freebox_virtual_machine.vm.mac
}

output "duckdns_fqdn" {
  description = "DuckDNS name for the Freebox."
  value       = "${var.duckdns_subdomain}.${local.duckdns_domain}"
}
