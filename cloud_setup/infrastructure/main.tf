terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.5"
    }
  }
}

resource "google_compute_instance" "postgres_instance" {
  name         = "pgsql-server"
  machine_type = var.instance_type
  zone         = "europe-west1-b"

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
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
  zone         = "europe-west1-b"

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
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

resource "google_compute_firewall" "allow_ssh_and_db" {
  name    = "allow-ssh-and-db"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22", "5432"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_lxc_communication" {
  name    = "allow-lxc-communication"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["8443"]
  }

  source_ranges = ["0.0.0.0/0"]
}
