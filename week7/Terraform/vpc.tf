terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.30.0"
    }
  }
}

provider "google" {
  project     = "class75"
  region      = "us-central1"
}

module "vpc" {
    source  = "terraform-google-modules/network/google//modules/vpc"
    version = "~> 18.0"

    project_id   = "class75-491118"
    network_name = "cam-vpc"

    shared_vpc_host = false
}