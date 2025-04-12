Terraform => infrastructure as code

cloud formation template from AWS is similar to terraform



you need to create the main.tf file and write all the configuration you want
then run commands


main.tf
provider "aws" {
 region = "us-east-1"  # Set your desired AWS region
}

resource "aws_instance" "example" {       # example is name if that instance, it will not reflect on aws
 ami           = "ami-084568db4383264d4"  # beacuse it is only to understand to terraform only
 instance_type = "t2.micro"
 subnet_id = "subnet-0d4071f3fc1caa2d8"
 key_name = "ubuntu-ppk-key"
}

 
terraform init => this will read the main.tf file and fetch the all requied details in .terraform dir

terraform plan  = > it will list out all the tings which will be get executed if apply command triged

terraform apply 
terraform apply -auto-approve

terraform destory