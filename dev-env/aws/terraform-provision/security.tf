resource "aws_security_group" "vnc_ssh_sg" {
  name = "poc_machine_access"
  description = "Open up vnc and ssh ports"
  vpc_id = data.aws_vpc.data_vpc.id



  ingress {
      description      = "SSH ingress"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["${trimspace(data.http.origin_ip.body)}/32"]
    }


  egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]

    }


  tags = {
    name: "PoC instance"
    state: "experimental"
  }
}

resource "aws_key_pair" "key" {
  public_key = file("/home/phiro/.ssh/id_rsa.pub")
  key_name = "poc_key_instance"


}