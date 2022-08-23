provider "aws" {
  region = "ap-northeast-1"
}

variable "instance_type" {
  type        = string
  description = "Instance type of EC2"

  validation {
    condition     = contains(["t2.micro", "t3.small"], var.instance_type)
    error_message = "Value not allow."
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "a_res" {
  count         = 5
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
}

output "ec2" {
  value = {
    public_ip = { for i, v in aws_instance.a_res : format("public_ip%d", i + 1) => v.public_ip }
  }
}
