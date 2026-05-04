resource "google_compute_instance" "vm" {
  name         = "cameron-hw-vm"
  machine_type = "n2-standard-2" 
  zone         = "us-central1-f"

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-stream-10" 
      size  = 100                             
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.private.id
    access_config {
    }
  }

  metadata_startup_script = file("${path.module}/../startup.sh")

  tags = ["ssh", "http", "http-server"]
  
  depends_on = [
    module.vpc
  ]
}