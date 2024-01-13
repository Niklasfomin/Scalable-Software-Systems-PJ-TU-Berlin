variable "ami_id" {
  description = "ami-0d118c6e63bcb554e"
  type        = string
}

variable "instance_type" {
  description = "EC2 Free Tier"
  default     = "c5.metal"
}

variable "ssh_key_name" {
  description = "Name of the SSH key pair in AWS"
  type        = string
}

variable "private_key_path" {
  description = "Path to the private SSH key on the local machine"
  type        = string
}
