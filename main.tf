

provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_instance" "example" {
  ami = "ami-8fd760f6" //type: hvm:ebs-ssd
  instance_type = "t2.micro"
  key_name = "centOS"

    tags {
    Name = "terraform-example"
  }
}

# Allow SSH access from anywhere
resource "aws_security_group" "allow_ssh" {
  name = "allow_ssh"
    description = "Allow ssh connections on port 22"

  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

output "public_ip" {
  value = "${aws_instance.example.public_ip}"
}

output "public_dns_name" {
  value = "${aws_instance.example.public_dns}"
}

//aws ec2 describe-instances --instance-ids i-0ad6ba1bfd6e3da65 --query "Reservations[].Instances[].PublicDnsName"

/*
* 1. terraform init
* 2. terraform plan
* 3. terraform apply
* 4. Get instance id of started server from terraform.tfstate
* 5. Use instance id to get public dns name to be able to remote to server
*/