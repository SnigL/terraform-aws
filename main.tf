provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_instance" "example" {
  ami = "ami-8fd760f6"
  instance_type = "t2.micro"
  key_name = "centOS"

  # Our Security group to allow SSH access
  security_groups = ["${aws_security_group.default.name}"]

    tags {
    Name = "terraform-example"
  }

# Default security group to access the instances via SSH
resource "aws_security_group" "default" {
  name        = "terraform_example"
  description = "Used in the terraform"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
