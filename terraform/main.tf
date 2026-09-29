terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }

    tls = {
      source = "hashicorp/tls"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

# Generate SSH key locally
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Upload public key to AWS
resource "aws_key_pair" "ssh" {
  key_name   = "alroma-key"
  public_key = tls_private_key.ssh.public_key_openssh
}

# Save private key locally
resource "local_sensitive_file" "ssh_private_key" {
  filename        = "${path.module}/alroma-key.pem"
  content         = tls_private_key.ssh.private_key_pem
  file_permission = "0400"
}

# Create security group
resource "aws_security_group" "web" {
  name        = "alroma-web"
  description = "Security group for web servers"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create web servers
resource "aws_instance" "web" {
  count = 3

  ami           = "ami-02e5204b675042e38"
  instance_type = "t3.micro"

  key_name = aws_key_pair.ssh.key_name

  vpc_security_group_ids = [
    aws_security_group.web.id
  ]

  tags = {
    Name = "web-${count.index + 1}"
  }
}
