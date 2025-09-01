terraform {
	required_providers {
		aws = {
			source  = "hashicorp/aws"
			version = "~> 5.92"
		}
	}

	required_version = ">= 1.2"
}

provider "aws" {
	region = var.zone
}

resource "aws_instance" "ashu-delete" {
	count = var.count_num
	ami = var.ami
	key_name = var.key
	instance_type = var.type_ty
	
	tags = {
		Name = "ashu-delete-${count.index + 1}"

	}
}
