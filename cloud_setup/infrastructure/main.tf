terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

resource "aws_instance" "postgres_instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.ssh_key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh_and_db.id]

#   provisioner "local-exec" {
#     command = "ansible-playbook -i '${self.public_ip},' ${path.module}/benchmark_setup/setup_postgres.yaml --private-key ${var.private_key_path}"
# }

}

resource "aws_instance" "hammerdb_instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.ssh_key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh_and_db.id]
}

resource "aws_security_group" "allow_ssh_and_db" {
  name        = "allow_ssh_and_db"
  description = "Allow SSH and DB traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


