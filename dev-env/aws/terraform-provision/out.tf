output "dev_machine_ip_address" {
  value = "ssh -i ~/.ssh/id_rsa ubuntu@${aws_instance.dev.public_ip}"
}