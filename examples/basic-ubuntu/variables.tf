variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "eu-west-1"
}

variable "key_name" {
  description = "Name of AWS key pair"
}

variable "instance_type" {
  default     = "t2.micro"
  description = "AWS instance type"
}

variable "ami_id" {
  default = "ami-8fd760f6"
  description = "Id of AMI"
}
