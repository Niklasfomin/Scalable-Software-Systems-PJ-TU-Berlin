terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

resource "google_compute_instance" "postgres_instance" {
  name         = "psql-server"
  machine_type = "n2-standard-8"
  zone         = "us-central1-b"

  boot_disk {
    initialize_params {
      image = "projects/ssws23/global/images/nested-vm-image"
    }
  }

  network_interface {
    network    = "default"
    access_config {}
  }

  metadata = {
    ssh-keys = "niklasfomin:${file(var.public_key_path)}"
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
  }

  advanced_machine_features {
    enable_nested_virtualization = true
  }
}

resource "google_compute_instance" "hammerdb_instance" {
  name         = "hammerdb-instance"
  machine_type = var.instance_type
  zone         = "us-central1-b"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network    = "default"
    access_config {}
  }

  metadata = {
    ssh-keys = "niklasfomin:${file(var.public_key_path)}"
  }
}

resource "google_compute_firewall" "allow_traffic" {
  name    = "allow-traffic"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["0-20000"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# Execute Ansible playbook
resource "null_resource" "run_ansible" {

  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = <<-EOT
      sleep 5 && \
      printf "[postgres]\\n${google_compute_instance.postgres_instance.network_interface[0].access_config[0].nat_ip}\\n\\n[hammerdb]\\n${google_compute_instance.hammerdb_instance.network_interface[0].access_config[0].nat_ip}\\n" > ../BenchmarkSetup/Ansible/hosts.ini && \
      ansible-playbook -i ../BenchmarkSetup/Ansible/hosts.ini ../BenchmarkSetup/Ansible/playbook.yaml --extra-vars "postgres_ip=${google_compute_instance.postgres_instance.network_interface[0].access_config[0].nat_ip}"
    EOT
  }
}
