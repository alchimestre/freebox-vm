locals {
  bytes_per_gib   = 1024 * 1024 * 1024
  duckdns_domain  = "duckdns.org"
  image_file      = "${path.module}/../image/out/freebox-vm.qcow2"
  image_path      = "${var.freebox_storage_dir}/freebox-vm-base.qcow2"
  vm_disk_path    = "${var.freebox_storage_dir}/${var.hostname}.qcow2"
  disk_size_bytes = var.disk_size_gib * local.bytes_per_gib

  port_forwards = {
    ssh         = 22
    http        = 80
    https       = 443
    forgejo_ssh = 2222
  }
}

resource "freebox_remote_file" "base_image" {
  source_url       = "${var.image_server_url}/freebox-vm.qcow2"
  destination_path = local.image_path
  checksum         = "sha256:${filesha256(local.image_file)}"
  parents          = true
}

resource "freebox_virtual_disk" "vm" {
  path         = local.vm_disk_path
  resize_from  = freebox_remote_file.base_image.destination_path
  virtual_size = local.disk_size_bytes
}

resource "freebox_virtual_machine" "vm" {
  name               = var.hostname
  vcpus              = var.vcpus
  memory             = var.memory_mb
  disk_path          = freebox_virtual_disk.vm.path
  disk_type          = "qcow2"
  enable_cloudinit   = true
  cloudinit_hostname = var.hostname
  cloudinit_userdata = templatefile("${path.module}/templates/user-data.yaml.tftpl", {
    hostname       = var.hostname
    ssh_public_key = var.ssh_public_key
  })
}

resource "freebox_dhcp_lease" "vm" {
  mac      = freebox_virtual_machine.vm.mac
  ip       = var.lan_ip
  hostname = var.hostname
  comment  = var.hostname
}

resource "freebox_virtual_machine_power" "vm" {
  vm_id       = freebox_virtual_machine.vm.id
  power_state = "running"
  depends_on  = [freebox_dhcp_lease.vm]
}

resource "freebox_port_forwarding" "vm" {
  for_each = local.port_forwards

  enabled          = true
  ip_protocol      = "tcp"
  target_ip        = var.lan_ip
  port_range_start = each.value
  comment          = "${var.hostname} ${each.key}"
}

resource "terraform_data" "duckdns_update" {
  triggers_replace = {
    subdomain = var.duckdns_subdomain
    ip        = var.freebox_public_ipv4
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/duckdns-update.sh"
    environment = {
      DUCKDNS_SUBDOMAIN = var.duckdns_subdomain
      DUCKDNS_IP        = var.freebox_public_ipv4
    }
  }
}
