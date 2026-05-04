# 1. Internal and External IP addresses
output "internal_ip" {
  value = google_compute_instance.vm.network_interface.0.network_ip
}

output "external_ip" {
  value = google_compute_instance.vm.network_interface.0.access_config.0.nat_ip
}

# 2. Name, ID, and Self_link attributes
output "vm_attributes" {
  value = {
    name      = google_compute_instance.vm.name
    id        = google_compute_instance.vm.instance_id
    self_link = google_compute_instance.vm.self_link
  }
}