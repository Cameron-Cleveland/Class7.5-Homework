resource "google_compute_subnetwork" "private" {
  name                     = "private-subnet"
  ip_cidr_range            = "10.0.0.0/18"
  region                   = "us-central1"
  network                  = module.vpc.network_name
  private_ip_google_access = true
}