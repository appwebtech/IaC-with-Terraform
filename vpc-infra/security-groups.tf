# Security Group Web
resource "aws_security_group" "web-server-sg-web" {
  name        = "SG-Web-${var.generic_names.name}-${var.generic_names.app}"
  description = "Allow HTTP/S inbound traffic"
  vpc_id      = aws_vpc.web-server-ec2_prod.id

  ingress {
    description = "Allow TLS port 80 inbound"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
    // ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  ingress {
    description = "Allow TLS port 8080 inbound from world"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    // ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    // ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = var.generic_names["name"],
    app = var.generic_names["app"]
  }
}

# SG lb
resource "aws_security_group" "lb-sg" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic to lb"
  vpc_id      = aws_vpc.web-server-ec2_prod.id

    ingress {
    description      = "TLS from world"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0", var.vpc_cidr_block]
    // ipv6_cidr_blocks = ["::/0"]
  }

    ingress {
    description      = "TLS from world"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    // ipv6_cidr_blocks = ["::/0"]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    // ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = var.generic_names["name"],
    app = var.generic_names["app"]
  }
}

# SG SSH
resource "aws_security_group" "web-server-sg-ssh" {
  name        = "SG-SSH-${var.generic_names.name}-${var.generic_names.app}"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.web-server-ec2_prod.id

  ingress {
    description = "Allow SSH, TLS on port 22"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
 
  }

  tags = {
    Name = var.generic_names["name"],
    app = var.generic_names["app"]
  }
}