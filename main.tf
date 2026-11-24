
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# 1. Create a new VPC
resource "aws_vpc" "project_vpc" {
  cidr_block           = "10.30.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name      = "Aryan-Project-03-VPC"
    Owner     = "Aryan Singh"
    Project   = "Capstone Project 3"
    ManagedBy = "Terraform"
  }
}

# 2. Find an available Availability Zone
data "aws_availability_zones" "available" {
  state = "available"
}

# 3. Create a subnet
resource "aws_subnet" "project_subnet" {
  vpc_id                  = aws_vpc.project_vpc.id
  cidr_block              = "10.30.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false

  tags = {
    Name      = "Aryan-Project-03-Subnet"
    Owner     = "Aryan Singh"
    Project   = "Capstone Project 3"
    ManagedBy = "Terraform"
  }
}

# 4. Create an EC2 security group
resource "aws_security_group" "ec2" {
  name_prefix = "project-03-cloudwatch-"
  description = "Security group for Project 3 EC2 monitoring"
  vpc_id      = aws_vpc.project_vpc.id

  # No inbound rules are required for CPU monitoring.

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "Aryan-Project-03-SG"
    Owner     = "Aryan Singh"
    Project   = "Capstone Project 3"
    ManagedBy = "Terraform"
  }
}

# 5. Find the latest Ubuntu 24.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name = "name"
    values = [
      "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
    ]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# 6. Create EC2 instance
resource "aws_instance" "monitoring" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  subnet_id = aws_subnet.project_subnet.id

  vpc_security_group_ids = [
    aws_security_group.ec2.id
  ]

  associate_public_ip_address = false
  monitoring                  = false

  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name      = "Aryan-Project-03-EC2"
    Owner     = "Aryan Singh"
    Project   = "Capstone Project 3"
    ManagedBy = "Terraform"
  }
}

# 7. Create CloudWatch CPU alarm
resource "aws_cloudwatch_metric_alarm" "cpu" {
  alarm_name        = "Aryan-Project-03-High-CPU"
  alarm_description = "Triggers when average EC2 CPU utilization exceeds 70% for two consecutive periods."

  comparison_operator = "GreaterThanThreshold"

  evaluation_periods  = 2
  datapoints_to_alarm = 2

  metric_name = "CPUUtilization"
  namespace   = "AWS/EC2"
  period      = 300
  statistic   = "Average"

  threshold = var.alarm_threshold

  treat_missing_data = "notBreaching"

  dimensions = {
    InstanceId = aws_instance.monitoring.id
  }

  tags = {
    Owner     = "Aryan Singh"
    Project   = "Capstone Project 3"
    ManagedBy = "Terraform"
  }
}
