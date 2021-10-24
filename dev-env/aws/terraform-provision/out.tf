output "dev_machine_ip_address" {
  value = "ssh -i ~/.ssh/id_rsa -L 5902:127.0.0.1:5901 ubuntu@${aws_instance.dev.public_ip}"
}