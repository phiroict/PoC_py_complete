
resource "aws_instance" "dev" {
  ami = data.aws_ami.dev_image.id
  instance_type = var.size
  vpc_security_group_ids = [aws_security_group.vnc_ssh_sg.id]
  subnet_id = data.aws_subnet.data_subnet.id
  monitoring = true
  key_name = aws_key_pair.key.key_name
  depends_on = [aws_key_pair.key]
  associate_public_ip_address = true
}