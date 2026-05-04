resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = module.vpc.network_name 
  
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}