terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

resource "aws_instance" "web" {
  count = 3

  ami           = "ami-02e5204b675042e38"
  instance_type = "t3.micro"

  key_name = "alroma-key"

  vpc_security_group_ids = [
    "sg-0e3ce38cda530bded"
  ]

  tags = {
    Name = "web-${count.index + 1}"
  }
}
