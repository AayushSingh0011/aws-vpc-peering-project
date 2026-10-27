variable "aws_region" {
  description = "AWS Region to deploy resources"
  type        = string
  default     = "ap-south-1"
}

variable "student_name" {
  description = "Name of the student for tagging"
  type        = string
  default     = "Student"
}

variable "key_name" {
  description = "Name of existing EC2 Key Pair in AWS"
  type        = string
  default     = "ewb-lab"
}

variable "admin_my_ip" {
  description = "Your current public IPv4 address with /32 (e.g. 203.0.113.25/32)"
  type        = string
  default     = "0.0.0.0/0"
}
