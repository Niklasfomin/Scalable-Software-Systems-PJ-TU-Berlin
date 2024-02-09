output "postgresql_instance_ip" {
  value = google_compute_instance.postgres_instance.network_interface[0].access_config[0].nat_ip
}

output "hammerdb_instance_ip" {
  value = google_compute_instance.hammerdb_instance.network_interface[0].access_config[0].nat_ip
}