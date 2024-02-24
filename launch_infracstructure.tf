# Create a VPC
resource "aws_vpc" "my-vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "prometheus_grafana VPC"
  }
}

# Create Web Public Subnet
resource "aws_subnet" "web-subnet" {
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-prometheus-grafana"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "prometheus IGW"
  }
}

# Create Web layber route table
resource "aws_route_table" "web-rt" {
  vpc_id = aws_vpc.my-vpc.id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "WebRT"
  }
}

# Create Web Subnet association with Web route table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.web-subnet.id
  route_table_id = aws_route_table.web-rt.id
 }


  # Create Web Security Group
resource "aws_security_group" "web-sg" {
    name        = "Web-SG"
    description = "Allow ssh inbound traffic"
    vpc_id      = aws_vpc.my-vpc.id
  
    ingress {
      description = "ssh from VPC"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    
  ingress {
    description = "http port"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
      description = "ssh from VPC Prometheus"
      from_port   = 9090
      to_port     = 9090
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
      description = "ssh from VPC node exporter"
      from_port   = 9100
      to_port     = 9100
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

  ingress {
      description = "ssh from VPC grafana"
      from_port   = 3000
      to_port     = 3000
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
      Name = "prometheus-SG"
    }
}
#data for amazon linux
data "aws_ami" "amazon_linux_2" {
    most_recent = true
  
    filter {
      name = "name"
      values = ["amzn2-ami-hvm-*-x86_64-ebs"]
    }
    owners = ["amazon"]
}

 
#create ec2 instances

//---
resource "aws_instance" "prometheus" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.aws_instance_type
  subnet_id              = aws_subnet.web-subnet.id
  vpc_security_group_ids = ["${aws_security_group.web-sg.id}"]
  key_name               = aws_key_pair.ec2_key.key_name
  user_data              = file("prometheus_script.sh")

  tags = {
    owner   = "prometheus"
    Environment = "dev"
  }
}

resource "aws_instance" "grafana" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.aws_instance_type
  subnet_id              = aws_subnet.web-subnet.id
  vpc_security_group_ids = ["${aws_security_group.web-sg.id}"]
  key_name               = aws_key_pair.ec2_key.key_name
  user_data              = file("grafana_script.sh")

    tags = {
    owner   = "grafana"
    Environment = "dev"
  }
}
resource "aws_instance" "client" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.aws_instance_type
  subnet_id              = aws_subnet.web-subnet.id
  vpc_security_group_ids = ["${aws_security_group.web-sg.id}"]
  key_name               = aws_key_pair.ec2_key.key_name
  user_data              = file("client_script.sh")

    tags = {
    owner   = "client"
    Environment = "dev"
  }
}