output "ami" {
  value       = data.aws_ami.web-server-ec2_prod.id
  description = "ami used to launch instances"
}

output "launch-config" {
  value       = aws_launch_configuration.web-server-launch-config.id
  description = "launch config for ami's"
}

output "cluster-asg" {
  value       = aws_autoscaling_group.web-server-ASG.id
  description = "placement group"
}

output "alb" {
  value       = aws_lb.web-server-lb.id
  description = "application load balancer"
}

output "vpc-id" {
  value       = aws_vpc.web-server-ec2_prod.id
  description = "vpc id"
}

output "vpc-igw" {
  value       = aws_internet_gateway.web-server-ig.id
  description = "igw"
}

output "rtb" {
  value       = aws_route_table.web-server-rtb.id
  description = "created rtb"
}

output "public-subs" {
  value       = values(aws_subnet.public_subnets)[*].id
  description = "List of created public subnet IDs"
}

output "private-subs" {
  value       = values(aws_subnet.private_subnets)[*].id
  description = "List of created private subnet IDs"
}

output "sg" {
  value = [
    aws_security_group.web-server-sg-web.id,
    aws_security_group.web-server-sg-ssh.id
  ]
  description = "security groups"
}
