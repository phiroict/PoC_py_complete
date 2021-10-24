data "aws_vpc" "data_vpc" {
  filter {
    name = "tag:Name"
    values = ["poc-dev-vpc"]
  }
}

data "aws_subnet" "data_subnet" {
  filter {

    name = "tag:Name"
    values = ["poc-dev-mainsubnet"]
  }
}

data "aws_caller_identity" "current" {}

data "aws_ami" "dev_image" {
  filter {
    name = "name"
    values = ["ubuntu-linux-dev-machine"]
  }
  owners = [data.aws_caller_identity.current.id]
}

data "http" "origin_ip" {
  url = "https://ipv4.icanhazip.com"
}