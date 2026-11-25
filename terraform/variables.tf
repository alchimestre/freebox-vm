variable "hostname" {
  description = "VM name on the Freebox, cloud-init hostname and DHCP hostname."
  type        = string
  default     = "freebox-vm"
}

variable "freebox_storage_dir" {
  description = "Freebox disk and folder for the image and VM disk, e.g. SSD/VMs. The disk must already exist."
  type        = string
  default     = "SSD/VMs"
}

variable "image_server_url" {
  description = "LAN URL the Freebox downloads image/out/freebox-vm.qcow2 from, without a trailing slash, for example http://192.168.1.12:8000."
  type        = string
}

variable "disk_size_gib" {
  description = "Virtual size of the VM disk in GiB; raise it later and restart the VM to grow the root filesystem."
  type        = number
  default     = 16
}

variable "vcpus" {
  description = "vCPUs of the VM."
  type        = number
  default     = 2
}

variable "memory_mb" {
  description = "Memory of the VM in MB."
  type        = number
  default     = 2048
}

variable "lan_ip" {
  description = "Static LAN address for the VM. Must be outside the Freebox DHCP pool."
  type        = string
  default     = "192.168.1.45"
}

variable "ssh_public_key" {
  description = "SSH public key authorised for the freebox user."
  type        = string
}

variable "duckdns_subdomain" {
  description = "DuckDNS subdomain (without .duckdns.org) that points at the Freebox."
  type        = string
}

variable "freebox_public_ipv4" {
  description = "Public IPv4 that DuckDNS should point at. Leave empty to use the address the update request comes from."
  type        = string
  default     = ""
}
