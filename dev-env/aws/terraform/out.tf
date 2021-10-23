output "aws_subnet" {
    value = aws_subnet.main.id
}

output "aws_vpc" {
    value = aws_vpc.dev.id
}
