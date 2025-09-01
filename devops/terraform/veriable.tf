variable "zone" {
	description = "zene to create the vm default is west one"
	type = string
	default = "us-east-1"
}

variable "count_num" {
	description = "how much resources you want? that count need to be here"
	type = number
	default = 3
}

variable "key"{
	description = "what is your key neme?"
	type = string
	default = "on-office-laptop"
}

variable "ami" {
	description = "which os you want"
	type = string
	default = "ami-020cba7c55df1f615"
}

variable "type_ty" { 
	description = "what kind of ec2 you want? is it free? then I want"
	type = string
	default = "t2.micro"
}
