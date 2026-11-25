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

variable "debian_image_url" {
  description = "arm64 Debian cloud image (qcow2) to download to the Freebox."
  type        = string
  default     = "https://cloud.debian.org/images/cloud/trixie/20261123-2671/debian-13-generic-arm64-20261123-2671.qcow2"
}

variable "debian_image_checksum" {
  description = "Checksum of debian_image_url, in the form sha256:<hex>."
  type        = string
  default     = "sha256:c7e96fd672cfd7af9ab4412468d911bd7ff5d7b15cbe94ffa4c5df2c72e659c2"
}

variable "disk_size_gib" {
  description = "Virtual size of the VM disk in GiB."
  type        = number
  default     = 110
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
