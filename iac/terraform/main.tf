terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ==============================================================================
# Amazon Linux 2023 Latest AMI
# ==============================================================================
data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# ==============================================================================
# VPC A (10.10.0.0/16)
# ==============================================================================
resource "aws_vpc" "vpc_a" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "ewb-vpc-a"
    Project = "EWB-VPC-Peering"
    Student = var.student_name
  }
}

resource "aws_subnet" "subnet_a_public" {
  vpc_id                  = aws_vpc.vpc_a.id
  cidr_block              = "10.10.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name    = "ewb-a-public"
    Project = "EWB-VPC-Peering"
    Student = var.student_name
  }
}

resource "aws_subnet" "subnet_a_private" {
  vpc_id                  = aws_vpc.vpc_a.id
  cidr_block              = "10.10.2.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name    = "ewb-a-private"
    Project = "EWB-VPC-Peering"
    Student = var.student_name
  }
}

resource "aws_internet_gateway" "igw_a" {
  vpc_id = aws_vpc.vpc_a.id

  tags = {
    Name    = "ewb-igw-a"
    Project = "EWB-VPC-Peering"
    Student = var.student_name
  }
}

# ==============================================================================
# VPC B (10.20.0.0/16)
# ==============================================================================
resource "aws_vpc" "vpc_b" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "ewb-vpc-b"
    Project = "EWB-VPC-Peering"
    Student = var.student_name
  }
}

resource "aws_subnet" "subnet_b_private" {
  vpc_id                  = aws_vpc.vpc_b.id
  cidr_block              = "10.20.1.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name    = "ewb-b-private"
    Project = "EWB-VPC-Peering"
    Student = var.student_name
  }
}

# ==============================================================================
# VPC PEERING CONNECTION
# ==============================================================================
resource "aws_vpc_peering_connection" "peering" {
  vpc_id      = aws_vpc.vpc_a.id
  peer_vpc_id = aws_vpc.vpc_b.id
  auto_accept = true

  tags = {
    Name    = "ewb-a-b-peer"
    Project = "EWB-VPC-Peering"
    Student = var.student_name
  }
}

# ==============================================================================
# ROUTE TABLES - VPC A
# ==============================================================================
resource "aws_route_table" "rt_a_public" {
  vpc_id = aws_vpc.vpc_a.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_a.id
  }

  route {
    cidr_block                = "10.20.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
  }

  tags = {
    Name    = "ewb-rt-a-public"
    Project = "EWB-VPC-Peering"
    Student = var.student_name
  }
}

resource "aws_route_table_association" "assoc_a_public" {
  subnet_id      = aws_subnet.subnet_a_public.id
  route_table_id = aws_route_table.rt_a_public.id
}

resource "aws_route_table" "rt_a_private" {
  vpc_id = aws_vpc.vpc_a.id

  route {
    cidr_block                = "10.20.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
  }

  tags = {
    Name    = "ewb-rt-a-private"
    Project = "EWB-VPC-Peering"
    Student = var.student_name
  }
}

resource "aws_route_table_association" "assoc_a_private" {
  subnet_id      = aws_subnet.subnet_a_private.id
  route_table_id = aws_route_table.rt_a_private.id
}

# ==============================================================================
# ROUTE TABLES - VPC B
# ==============================================================================
resource "aws_route_table" "rt_b_private" {
  vpc_id = aws_vpc.vpc_b.id

  route {
    cidr_block                = "10.10.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
  }

  tags = {
    Name    = "ewb-rt-b-private"
    Project = "EWB-VPC-Peering"
    Student = var.student_name
  }
}

resource "aws_route_table_association" "assoc_b_private" {
  subnet_id      = aws_subnet.subnet_b_private.id
  route_table_id = aws_route_table.rt_b_private.id
}

# ==============================================================================
# SECURITY GROUPS
# ==============================================================================
resource "aws_security_group" "sg_bastion" {
  name        = "ewb-sg-bastion"
  description = "Allow SSH from admin"
  vpc_id      = aws_vpc.vpc_a.id

  ingress {
    description = "SSH from admin"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "ewb-sg-bastion"
    Project = "EWB-VPC-Peering"
    Student = var.student_name
  }
}

resource "aws_security_group" "sg_app_a" {
  name        = "ewb-sg-app-a"
  description = "Allow SSH from Bastion and ICMP from App-B"
  vpc_id      = aws_vpc.vpc_a.id

  ingress {
    description = "SSH from Bastion private IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.10.1.10/32"]
  }

  ingress {
    description = "ICMP Echo from App-B"
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["10.20.1.10/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "ewb-sg-app-a"
    Project = "EWB-VPC-Peering"
    Student = var.student_name
  }
}

resource "aws_security_group" "sg_app_b" {
  name        = "ewb-sg-app-b"
  description = "Allow SSH from Bastion and ICMP from App-A"
  vpc_id      = aws_vpc.vpc_b.id

  ingress {
    description = "SSH from Bastion private IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.10.1.10/32"]
  }

  ingress {
    description = "ICMP Echo from App-A"
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["10.10.2.10/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "ewb-sg-app-b"
    Project = "EWB-VPC-Peering"
    Student = var.student_name
  }
}

# ==============================================================================
# EC2 INSTANCES
# ==============================================================================
resource "aws_instance" "bastion" {
  ami                         = data.aws_ssm_parameter.al2023_ami.value
  instance_type               = "t3.micro"
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.subnet_a_public.id
  private_ip                  = "10.10.1.10"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.sg_bastion.id]

  root_block_device {
    volume_size           = 10
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name    = "ewb-bastion"
    Project = "EWB-VPC-Peering"
    Student = var.student_name
  }
}

resource "aws_instance" "app_a" {
  ami                         = data.aws_ssm_parameter.al2023_ami.value
  instance_type               = "t3.micro"
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.subnet_a_private.id
  private_ip                  = "10.10.2.10"
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.sg_app_a.id]

  root_block_device {
    volume_size           = 10
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name    = "ewb-app-a"
    Project = "EWB-VPC-Peering"
    Student = var.student_name
  }
}

resource "aws_instance" "app_b" {
  ami                         = data.aws_ssm_parameter.al2023_ami.value
  instance_type               = "t3.micro"
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.subnet_b_private.id
  private_ip                  = "10.20.1.10"
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.sg_app_b.id]

  root_block_device {
    volume_size           = 10
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name    = "ewb-app-b"
    Project = "EWB-VPC-Peering"
    Student = var.student_name
  }
}
