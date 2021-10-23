resource "aws_vpc" "dev" {
  cidr_block       = "10.1.0.0/24"
  instance_tenancy = "default"

  tags = {
    Name = "dev-vpc"
  }
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.dev.id
  cidr_block = "10.1.0.0/26"

  tags = {
    Name = "Main subnet"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.dev.id

  tags = {
    Name = "main"
  }
}




resource "aws_route" "inet_route" {
  route_table_id            = aws_vpc.dev.default_route_table_id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.gw.id
  depends_on                = [aws_vpc.dev]
}