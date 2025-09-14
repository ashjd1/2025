resource "aws_instance" "dev" {
    ami             = var.ashu_ami
    tags            = {    
      Name          =    var.ashu_name
    }
    instance_type   = var.ashu_type
    key_name        = var.ashu_key
    subnet_id       = var.ashu_subnet
  # 👇 Attach existing SG
  vpc_security_group_ids = ["sg-0f420010e39e12c23"]

}
