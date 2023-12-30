# VPC Configuration
resource "aws_vpc" "web-server-ec2_prod" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.generic_names["name"],
    app  = var.generic_names["app"]
  }
}

# Create IGW
resource "aws_internet_gateway" "web-server-ig" {
  vpc_id = aws_vpc.web-server-ec2_prod.id

  tags = {
    name = var.generic_names["name"],
    app  = var.generic_names["app"]
  }
}

# Create route table
resource "aws_route_table" "web-server-rtb" {
  vpc_id = aws_vpc.web-server-ec2_prod.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.web-server-ig.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.web-server-ig.id
  }

  tags = {
    name = var.generic_names["name"],
    app  = var.generic_names["app"]
  }
}

# Route table association for public_subnet
resource "aws_route_table_association" "public_subnet_association" {
  // subnet_id      = [for subnet in aws_subnet.public_subnets : subnet.id]
  for_each = aws_subnet.public_subnets
  subnet_id = each.value.id
  route_table_id = aws_route_table.web-server-rtb.id

  depends_on = [aws_subnet.public_subnets]
}


# Public subnets
resource "aws_subnet" "public_subnets" {
  for_each                = { for index, az_name in local.az_names : index => az_name }
  vpc_id                  = aws_vpc.web-server-ec2_prod.id
  cidr_block              = var.cidr_range_public_subnet[each.key]
  availability_zone       = local.az_names[each.key]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.generic_names["name"]}-${var.generic_names["app"]}-PubSubnet-${each.key}"
  }
}

# Private subnets
resource "aws_subnet" "private_subnets" {
  for_each                = { for index, az_name in local.az_names : index => az_name }
  vpc_id                  = aws_vpc.web-server-ec2_prod.id
  cidr_block              = var.cidr_range_private_subnet[each.key]
  availability_zone       = local.az_names[each.key]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.generic_names["name"]}-${var.generic_names["app"]}-PrivSubnet-${each.key}"
  }
}



