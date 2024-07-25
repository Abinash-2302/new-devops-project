provider "aws" {
  region = var.region
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone = "${var.region}a"
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = "${var.region}a"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "public_sg" {
  vpc_id = aws_vpc.main.id
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

resource "aws_security_group" "private_sg" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.public.cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "frontend" {
  ami           = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 AMI (example)
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public.id
  key_name      = var.key_name
  security_groups = [aws_security_group.public_sg.name]

  provisioner "file" {
    source      = "frontend.sh"
    destination = "/tmp/frontend.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/frontend.sh",
      "/tmp/frontend.sh"
    ]
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("Abinash@2304.pem")
    host        = self.public_ip
  }
}

resource "aws_instance" "backend" {
  ami           = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 AMI (example)
  instance_type = var.instance_type
  subnet_id     = aws_subnet.private.id
  key_name      = var.key_name
  security_groups = [aws_security_group.private_sg.name]

  provisioner "file" {
    source      = "backend.sh"
    destination = "/tmp/backend.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/backend.sh",
      "/tmp/backend.sh"
    ]
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("/Ubuntu/home/abianshsahoo_123/MyKeyPair1.pem")
    host        = self.private_ip
  }
}
