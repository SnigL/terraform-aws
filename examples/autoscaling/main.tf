########################################
# Provider and access details
########################################

provider "aws" {
  region = "${var.aws_region}"
}

########################################
# Elastic Load Balancer
########################################

resource "aws_elb" "web-elb" {
  name = "web-elb"

  # The same availability zone as our instances
  availability_zones = ["${split(",", var.availability_zones)}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }
}

########################################
# Autoscaling Group
########################################

resource "aws_autoscaling_group" "web-asg" {
  availability_zones   = ["${split(",", var.availability_zones)}"]
  name                 = "web-asg"
  max_size             = "${var.asg_max}"
  min_size             = "${var.asg_min}"
  desired_capacity     = "${var.asg_desired}"
  force_delete         = true
  launch_configuration = "${aws_launch_configuration.web-lc.name}"
  load_balancers       = ["${aws_elb.web-elb.name}"]

  enabled_metrics = [
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupMaxSize",
    "GroupMinSize",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]

  tag {
    key                 = "Name"
    value               = "web-asg"
    propagate_at_launch = "true"
  }
}

########################################
# Autoscaling Group Policy (increase)
########################################

resource "aws_autoscaling_policy" "web-asg-policy-increase" {
  autoscaling_group_name = "${aws_autoscaling_group.web-asg.name}"
  name                   = "web-asg-policy-increase"
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  scaling_adjustment     = 1
}

########################################
# Monitor CPU Utilization
########################################

resource "aws_cloudwatch_metric_alarm" "web-lc-cpualarm-high" {
  alarm_name          = "web-lc-cpualarm-high"
  alarm_description   = "This metric monitor EC2 instance cpu utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "60"

  alarm_actions = ["${aws_autoscaling_policy.web-asg-policy-increase.arn}"]
}

########################################
# Autoscaling Group Policy (decrease)
########################################

resource "aws_autoscaling_policy" "web-asg-policy-decrease" {
  autoscaling_group_name = "${aws_autoscaling_group.web-asg.name}"
  name                   = "web-asg-policy-decrease"
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  scaling_adjustment     = -1
}

########################################
# Monitor CPU Utilization
########################################

resource "aws_cloudwatch_metric_alarm" "web-lc-cpualarm-low" {
  alarm_name          = "web-lc-cpualarm-low"
  alarm_description   = "This metric monitor EC2 instance cpu utilization"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "40"

  alarm_actions = ["${aws_autoscaling_policy.web-asg-policy-decrease.arn}"]
}

########################################
# Application server configuration
########################################

resource "aws_launch_configuration" "web-lc" {
  name          = "web-lc"
  image_id      = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type = "${var.instance_type}"

  # Security group
  security_groups = ["${aws_security_group.web-sg.id}"]
  user_data       = "${file("userdata.sh")}"
  key_name        = "${var.key_name}"
}

########################################
# Security group
########################################

resource "aws_security_group" "web-sg" {
  name        = "web-sg"
  description = "Used in the terraform"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
