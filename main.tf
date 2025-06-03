##############################
# provider.tf
##############################
provider "aws" {
  region = "us-east-1"
}

##############################
# vpc.tf
##############################
resource "aws_vpc" "myvpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags = {
    Name = "my-vpc"
  }
}

resource "aws_subnet" "mysubnet1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet1"
  }
}

resource "aws_subnet" "mysubnet2" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet2"
  }
}

resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "my-igw"
  }
}

resource "aws_route_table" "myrt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myigw.id
  }

  tags = {
    Name = "my-rt"
  }
}

resource "aws_route_table_association" "ass1" {
  subnet_id      = aws_subnet.mysubnet1.id
  route_table_id = aws_route_table.myrt.id
}

resource "aws_route_table_association" "ass2" {
  subnet_id      = aws_subnet.mysubnet2.id
  route_table_id = aws_route_table.myrt.id
}

##############################
# security_groups.tf
##############################
resource "aws_security_group" "mysg" {
  name        = "terraform-sg"
  description = "Allow all traffic"
  vpc_id      = aws_vpc.myvpc.id

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

##############################
# launch_template.tf
##############################
resource "aws_launch_template" "mylt" {
  name          = "terraform-lt"
  description   = "v1"
  image_id      = "ami-0e58b56aa4d64231b"
  instance_type = "t2.micro"
  key_name      = "key"
  vpc_security_group_ids = [aws_security_group.mysg.id]

  placement {
    availability_zone = "us-east-1a"
  }
}

##############################
# elb.tf
##############################
resource "aws_elb" "myelb" {
  name            = "terraform-lb"
  subnets         = [aws_subnet.mysubnet1.id, aws_subnet.mysubnet2.id]
  security_groups = [aws_security_group.mysg.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}

##############################
# autoscaling.tf
##############################
resource "aws_autoscaling_group" "myasg" {
  name                 = "terraform-asg"
  min_size             = 2
  max_size             = 6
  desired_capacity     = 2
  health_check_type    = "EC2"
  load_balancers       = [aws_elb.myelb.name]
  vpc_zone_identifier  = [aws_subnet.mysubnet1.id, aws_subnet.mysubnet2.id]

  launch_template {
    id      = aws_launch_template.mylt.id
  }
}

##############################
# outputs.tf
##############################
output "elb_dns_name" {
  value = aws_elb.myelb.dns_name
}
