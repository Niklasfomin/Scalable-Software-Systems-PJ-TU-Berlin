terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

resource "google_compute_instance" "postgres_instance" {
  name         = "pgsql-server"
  machine_type = var.instance_type
  zone         = "northamerica-northeast1-b"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata = {
    ssh-keys = "niklasfomin:${file(var.public_key_path)}"
  }
}


resource "google_compute_instance" "hammerdb_instance" {
  name         = "hammerdb-instance"
  machine_type = var.instance_type
  zone         = "northamerica-northeast1-b"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata = {
    ssh-keys = "niklasfomin:${file(var.public_key_path)}"
  }
}

resource "google_compute_firewall" "allow_all_traffic" {
  name    = "allow-all-traffic"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = ["0.0.0.0/0"]
}
