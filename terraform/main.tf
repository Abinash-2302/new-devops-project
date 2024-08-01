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
resource "aws_security_group" "bastion_sg" {
  name        = "bastion_sg"
  description = "Security group for bastion host"
  vpc_id      = aws_vpc.main.id

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
resource "aws_s3_bucket" "docker_bucket" {
  bucket = "abinash2304"
  acl    = "private"

  tags = {
    Name = "DockerInstallationFiles"
  }
}
resource "aws_s3_bucket_object" "docker_install_files" {
  bucket = aws_s3_bucket.docker_bucket.bucket
  key    = "docker/install.sh"  # Path to your installation script in the bucket
  source = "/home/abianshsahoo_123/docker/install.sh"
  acl    = "private"
}
resource "aws_iam_role" "s3_access" {
  name = "s3-access"
  assume_role_policy = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "Service": "ubuntu.amazonaws.com"
          },
          "Action": "sts:AssumeRole"
        }
      ]
    }
  EOF
}

resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = aws_iam_role.s3_access.name
  policy_arn = aws_iam_policy.s3_access.arn
}
resource "aws_iam_policy" "s3_access" {
  name        = "s3-access"
  description = "Policy for accessing S3 bucket"
  policy      = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": "s3:GetObject",
          "Resource": "arn:aws:s3:::${aws_s3_bucket.docker_bucket.bucket}/*"
        }
      ]
    }
  EOF
}
resource "aws_iam_instance_profile" "s3_access" {
  name = "s3-access"
  role = aws_iam_role.s3_access.name
}

resource "aws_security_group" "private_instance_sg" {
  name        = "private_instance_sg"
  description = "Security group for private instance"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
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
  
  key_name       = var.key_name
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  subnet_id     = aws_subnet.public.id
  tags = {
    Name = "frontend"
  }
  
  
  provisioner "remote-exec" {
    inline =[
      "mkdir tmp",
      "echo Hello, World! > /tmp/hello.txt"
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
  iam_instance_profile = aws_iam_instance_profile.s3_access.name
  vpc_security_group_ids = [aws_security_group.private_instance_sg.id]
  tags ={
    Name ="backend"
}
   provisioner "remote-exec" {
    inline = [
      "echo Hello, World! > /tmp/hello.txt"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("/home/abianshsahoo_123/MyKeyPair1.pem")
      host        = aws_instance.backend.private_ip
      bastion_host = aws_instance.frontend.public_ip
      bastion_port = 22
      bastion_user = "ubuntu"
      bastion_private_key = file("/home/abianshsahoo_123/MyKeyPair1.pem")
 }
  }
}
