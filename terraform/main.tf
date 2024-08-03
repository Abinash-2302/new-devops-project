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
  map_public_ip_on_launch = true
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
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.public.id
}


# Security Group
resource "aws_security_group" "app" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
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
resource "aws_security_group" "backend" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
   security_groups = [aws_security_group.app.id]

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
  ami           = "ami-0c2af51e265bd5e0e"  # Replace with the desired AMI ID
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public.id
  key_name       = var.key_name
  vpc_security_group_ids = [aws_security_group.app.id]
  tags = {
    Name = "frontend"
  }
  provisioner file{
 source = "/home/abianshsahoo_123/2-tier-app/frontend.sh"
 destination = "/home/ubuntu/frontend.sh"

 
  connection {
      type        = "ssh"
      user        = "ubuntu"  # Update as necessary
      private_key = file("/home/abianshsahoo_123/MyKeyPair1.pem")  # Update with your key file path
      host        = self.public_ip
    }

}
    



  provisioner "remote-exec" {
    inline = [
      "mkdir tmp",
      "chmod +x /home/ubuntu/frontend.sh"
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"  # Update as necessary
      private_key = file("/home/abianshsahoo_123/MyKeyPair1.pem")  # Update with your key file path
      host        = self.public_ip
    }
  }

}
# Launch Backend EC2 Instance
resource "aws_instance" "backend" {
  ami           = "ami-0c2af51e265bd5e0e"  # Replace with the desired AMI ID
  instance_type = var.instance_type
  subnet_id     = aws_subnet.private.id
  key_name       = var.key_name
 vpc_security_group_ids = [aws_security_group.backend.id]
  tags = {
    Name = "backend"
  }
  

 provisioner file{
 source = "/home/abianshsahoo_123/2-tier-app/backend.sh"
 destination = "/home/ubuntu/backend.sh"

 connection {
      type        = "ssh"
      user        = "ubuntu"  # Update as necessary
      private_key = file("/home/abianshsahoo_123/MyKeyPair1.pem")  # Update with your key file path
      host        = self.public_ip
    }

  }
  

  provisioner "remote-exec" {
    inline = [
      "mkdir tmp",
      "chmod +x /home/ubuntu/backend.sh"

    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"  # Update as necessary
      private_key = file("/home/abianshsahoo_123/MyKeyPair1.pem")  # Update with your key file path
      host        = self.public_ip
    }

  }
}
