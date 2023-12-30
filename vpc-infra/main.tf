provider "aws" {
  region = var.aws_region
}

# Create Avaialability Zones
data "aws_availability_zones" "web-server-AZs" {
  state = "available"
}

locals {
  az_names = data.aws_availability_zones.azs.names
}

# Fetch AMI from AWS (I will be hosting a webserver in EC2 ~ Linux AMI)
data "aws_ami" "web-server-ec2_prod" {
  most_recent      = true
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_availability_zones" "azs" {
  state = "available"
}

# Launch Config
resource "aws_launch_configuration" "web-server-launch-config" {
  name_prefix   = "${var.generic_names.name}-${var.generic_names.app}-LaunchConfig"
  image_id      = data.aws_ami.web-server-ec2_prod.id
  instance_type = var.instance_type["large-apps"]
  user_data     = file("app-script.sh")

  metadata_options { http_endpoint = "enabled" }

  security_groups = [
    aws_security_group.web-server-sg-web.id,
    aws_security_group.web-server-sg-ssh.id
  ]
  lifecycle {
    create_before_destroy = true
  }
}

# Create Placement Group & ASG
resource "aws_placement_group" "web-server-placement-group" {
  name     = "${var.generic_names.name}-${var.generic_names.app}-PlacementG"
  strategy = "spread"
}

# Target group
resource "aws_lb_target_group" "web-server-target-group" {
  name        = "${var.generic_names.name}-${var.generic_names.app}-TargetG"
  target_type = "alb"
  port        = 80
  protocol    = "TCP"
  vpc_id      = aws_vpc.web-server-ec2_prod.id
  lifecycle { create_before_destroy=true }

    health_check {
    path = "/api/1/resolve/default?path=/service/my-service"
    port = 2001
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 2
    interval = 5
    matcher = "200"
  }
}


# Create ASG
resource "aws_autoscaling_group" "web-server-ASG" {
  name                      = "${var.generic_names.name}-${var.generic_names.app}-ASG"
  max_size                  = 3
  desired_capacity          = 2
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  // load_balancers = aws_lb.web-server-lb.id
  force_delete              = true
  placement_group           = aws_placement_group.web-server-placement-group.id
  launch_configuration      = aws_launch_configuration.web-server-launch-config.id
  vpc_zone_identifier       = [for subnet in aws_subnet.public_subnets : subnet.id]

  instance_maintenance_policy {
    min_healthy_percentage = 90
    max_healthy_percentage = 120
  }

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]
  metrics_granularity = "1Minute"

  initial_lifecycle_hook {
    name                 = "${var.generic_names.name}-${var.generic_names.app}-cycle-hook"
    default_result       = "CONTINUE"
    heartbeat_timeout    = 2000
    lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"

    notification_metadata = jsonencode({
      env = "prod"
    })

  }

  tag {
    key                 = "web-app"
    value               = "prod"
    propagate_at_launch = true
  }

  timeouts {
    delete = "15m"
  }

  tag {
    key                 = "web-app"
    value               = "prod"
    propagate_at_launch = false
  }

}

# ASG policy
resource "aws_autoscaling_policy" "web-server-asg-policy" {
  name                   = "${var.generic_names.name}-${var.generic_names.app}-Policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.web-server-ASG.id

}

# Policy to attach to s3-access-role
resource "aws_iam_role_policy" "lifecycle_hook_notification" {
  name = "${var.generic_names.name}-${var.generic_names.app}-Policy-lifecycle_hook-notification"
  role = aws_iam_role.s3-access-role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "LifecycleHookSQS",
            "Effect": "Allow",
            "Action": [
                "sqs:SendMessage"
            ],
            "Resource": "arn:aws:sqs:${var.aws_region}:${var.aws_account_id}:${var.generic_names.name}-${var.generic_names.app}-sqs-queue"
        }
    ]
}
EOF
}


# Role permission for ASG life cycle hook
resource "aws_iam_role" "web-server-launch-config-role" {
  name = "web-server-launch-config-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  ]
}


# Role for S3 access
resource "aws_iam_role" "s3-access-role" {
  name = "s3-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "autoscaling.amazonaws.com"
        }
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  ]
}


# Cloudwatch ASG trigger alarm (Upscaling)
resource "aws_cloudwatch_metric_alarm" "web-server-cloudwatch-alarm-up" {
  alarm_name                = "${var.generic_names.name}-${var.generic_names.app}-CloudWatch-alarm-UP"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 2
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = 120
  statistic                 = "Average"
  threshold                 = 75
  alarm_description         = "Monitor EC2 CPU utilization"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web-server-ASG.id
  }
  insufficient_data_actions = []
}

# Cloudwatch ASG trigger alarm (Downscaling)
resource "aws_cloudwatch_metric_alarm" "web-server-cloudwatch-alarm-down" {
  alarm_name                = "${var.generic_names.name}-${var.generic_names.app}-CloudWatch-alarm-DOWN"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = 2
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = 120
  statistic                 = "Average"
  threshold                 = 30
  alarm_description         = "Monitor EC2 CPU utilization"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web-server-ASG.id
  }
  insufficient_data_actions = []
}


# Create LB (application load balancer)
resource "aws_lb" "web-server-lb" {
  name               = "${var.generic_names.name}-${var.generic_names.app}-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb-sg.id]
  subnets            = [for subnet in aws_subnet.public_subnets : subnet.id]
  enable_cross_zone_load_balancing = true

  enable_deletion_protection = true

  # Created in a previous project
  access_logs {
    bucket  = "cdn-logs-joseph-resume.31ca1b73"
    prefix  = "web-server-lb-logs"
    enabled = false
  }
}


# Lb role policy to access s3
resource "aws_iam_role_policy" "web-server-lb_s3_access" {
  name = "${var.generic_names.name}-${var.generic_names.app}-LB-S3-Access"
  role = aws_iam_role.web-server-launch-config-role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::cdn-logs-joseph-resume.31ca1b73/*"
    }
  ]
}
EOF
}

# Lb listener
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.web-server-lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-server-target-group.arn
  }
}

# SQS queue
resource "aws_sqs_queue" "web-server_queue" {
  name = "${var.generic_names.name}-${var.generic_names.app}-sqs-queue"
}

# IAM role for SQS
resource "aws_iam_role" "web-server-sqs_role" {
  name = "example-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "autoscaling.amazonaws.com"
        }
      }
    ]
  })
}


