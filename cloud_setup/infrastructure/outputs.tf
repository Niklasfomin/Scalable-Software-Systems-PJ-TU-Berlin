output "postgresql_instance_ip" {
  value = aws_instance.postgres_instance.public_ip
}

output "hammerdb_instance_ip" {
  value = aws_instance.hammerdb_instance.public_ip
}
