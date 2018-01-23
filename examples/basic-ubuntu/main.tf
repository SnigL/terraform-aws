provider "aws" {
  region = "${var.aws_region}"
}

# Get latest build of Ubuntu 16.04
data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
    }

    owners = ["099720109477"] # Canonical
}

resource "aws_instance" "example" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.instance_type}"
  key_name      = "${var.key_name}"
  user_data     = "${file("user_data/user_data.sh")}"

  # Our Security group to allow SSH access
  security_groups = ["${aws_security_group.default.name}"]

    tags {
    Name = "terraform-example"
  }

}

# Default security group to access the instances via SSH
resource "aws_security_group" "default" {
  name        = "ubuntu_example"
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
