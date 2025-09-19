resource "aws_instance" "example" {
 ami           = var.instance_ami
 instance_type = var.instance_type
 subnet_id     = var.instance_subnet
 key_name      = var.instance_key
 tags = {
  Name = var.instance_name
 }
}