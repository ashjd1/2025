output "ashu_id" {
    value = aws_instance.dev.id
}

output "ashu_public_id" {
    value = aws_instance.dev.public_ip
}
