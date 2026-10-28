resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

tags = {
  Name        = "${var.project_week2}-${terraform.workspace}-vpc"
  Environment = terraform.workspace
}
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_week2}-${terraform.workspace}-igw"
    Environment = terraform.workspace
  }
}


resource "aws_subnet" "public" {
  count = length(var.availability_zones)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_week2}-${terraform.workspace}-public-${count.index}"
    Environment = terraform.workspace
  }
}

resource "aws_security_group" "web_sg" {
  name = "${var.project_week2}-${terraform.workspace}-web-sg"
  description = "Allow HTTP and SSH"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
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

  tags = {
    Name = "${var.project_week2}-${terraform.workspace}-web-sg"
    Environment = terraform.workspace
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_instance" "web" {
  count                  = var.instance_count
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_types[terraform.workspace]
  subnet_id              = aws_subnet.public[count.index % length(var.availability_zones)].id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name        = "${var.project_week2}-${terraform.workspace}-web-${count.index}"
    Environment = terraform.workspace
  }
}

resource "aws_s3_bucket" "app_bucket" {
  bucket = "${var.bucket_prefix}-${terraform.workspace}-cloud-lab-739284"

  tags = {
    Name        = "${var.project_week2}-${terraform.workspace}-app-bucket"
    Environment = terraform.workspace
  }
}

resource "aws_s3_bucket_versioning" "app_bucket" {
  bucket = aws_s3_bucket.app_bucket.id

  versioning_configuration {
    status = terraform.workspace == "dev" ? "Suspended" : "Enabled"
  }
}


resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  count               = terraform.workspace == "prod" ? 1 : 0
  alarm_name          = "${terraform.workspace}-high-cpu-usage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 80


  dimensions = {
    InstanceId = aws_instance.web[0].id
  }

tags = {
  Name        = "${terraform.workspace}-high-cpu-usage"
  Environment = terraform.workspace
}
  alarm_description = "This alarm monitors EC2 CPU utilization"
  }