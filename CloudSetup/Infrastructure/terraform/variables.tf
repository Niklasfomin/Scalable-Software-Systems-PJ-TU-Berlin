variable "instance_type" {
  description = "GCP instance type"
  type        = string
  default     = "n2d-standard-2"
}

variable "public_key_path" {
  description = "Path to the public SSH key on the local machine"
  type        = string
}
