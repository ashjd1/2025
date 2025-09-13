output "ashu_id" {
    value = aws_instance.dev.ip
}

output "ashu_public_id" {
    value = aws_instance.dev.public_id
}