output "public_IP" {
	description = "this will provides you public ip"
	value = aws_instance.ashu-delete[*].public_ip
}

output "instance_id" {
	description = "this will give you ip of instance"
	value = aws_instance.ashu-delete[*].id
}
