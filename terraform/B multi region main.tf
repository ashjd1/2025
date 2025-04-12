write main.tf for multi region


you will need to check the official documentation to wtite main.tf 
beacused there are multiple things, names and configuration you cant remember everything,
so you need to refer docs


you can create resources in multiple region in single main.tf file 
you will need to specifis the alias and provider, example as below 


main.tf

provider "aws" {
  alias = "us-east-1"
  region = "us-east-1"
}

provider "aws" {
  alias = "us-west-2"
  region = "us-west-2"
}

resource "aws_instance" "example" {
  ami = "ami-0123456789abcdef0"
  instance_type = "t2.micro"
  provider = "aws.us-east-1"
}

resource "aws_instance" "example2" {
  ami = "ami-0123456789abcdef0"
  instance_type = "t2.micro"
  provider = "aws.us-west-2"
}