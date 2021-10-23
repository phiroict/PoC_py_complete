packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "aws_subnet" {}
variable "aws_vpc" {}

source "amazon-ebs" "ubuntu" {
  ami_name      = "ubuntu-linux-dev-machine"
  instance_type = "m5.large"
  region        = "ap-southeast-2"
  subnet_id     = var.aws_subnet
  vpc_id        = var.aws_vpc
  associate_public_ip_address = true
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  name = "argocd-poc-dev-machine"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]
}
