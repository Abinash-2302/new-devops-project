provider "aws" {
  region = var.region
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "main-vpc"
  }
}

# Create Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet"
  }
}

# Create Private Subnet
resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidr
  availability_zone       = "ap-south-1a"
  tags = {
    Name = "private-subnet"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

# Create a Route Table for the Public Subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Group
resource "aws_security_group" "app" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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

# Launch Frontend EC2 Instance
resource "aws_instance" "frontend" {
  ami           = "ami-0c55b159cbfafe1f0"  # Replace with the desired AMI ID
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public.id
  key_name       = var.key_name
  security_groups = [aws_security_group.app.name]
  tags = {
    Name = "frontend"
  }
  
  provisioner "file" {
    source      = "../frontend/dockerfile"
    destination = "/tmp/Dockerfile"
  }
  
  provisioner "remote-exec" {
    inline = [
      "cd /tmp",
      "docker build -t frontend-app .",
      "docker run -d -p 80:80 frontend-app"
    ]
    connection {
      type        = "ssh"
      user        = "ec2-user"  # Update as necessary
      private_key = file("~/MyKeyPair1.pem")  # Update with your key file path
      host        = self.public_ip
    }
  }
}

# Launch Backend EC2 Instance
resource "aws_instance" "backend" {
  ami           = "ami-0c55b159cbfafe1f0"  # Replace with the desired AMI ID
  instance_type = var.instance_type
  subnet_id     = aws_subnet.private.id
  key_name       = var.key_name
  security_groups = [aws_security_group.app.name]
  tags = {
    Name = "backend"
  }
  
  provisioner "file" {
    source      = "../backend/dockerfile"
    destination = "/tmp/Dockerfile"
  }
  
  provisioner "remote-exec" {
    inline = [
      "cd /tmp",
      "docker build -t backend-app .",
      "docker run -d -p 3000:3000 backend-app"
    ]
    connection {
      type        = "ssh"
      user        = "ec2-user"  # Update as necessary
      private_key = file("~/MyKeyPair1.pem")  # Update with your key file path
      host        = self.private_ip
    }
  }
}