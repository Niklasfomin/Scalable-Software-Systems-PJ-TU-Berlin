variable "ami_id" {
  description = "ami-04272d3cdef346dfe"
  type        = string
}

variable "instance_type" {
  description = "EC2 Free Tier"
  default     = "t2.micro"
}

variable "ssh_key_name" {
  description = "Name of the SSH key pair in AWS"
  type        = string
}

variable "private_key_path" {
  description = "Path to the private SSH key on the local machine"
  type        = string
}
