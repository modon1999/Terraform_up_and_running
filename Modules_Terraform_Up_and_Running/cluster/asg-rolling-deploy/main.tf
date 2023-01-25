#========== Version ===========
# 
# terraform {
#
#   # Требуем исключительно версию Terraform 1.1.6
#
#   required_version = "= 1.1.6"
#
# }

#========== Local variables ===========

locals {
  http_port    = 80
  any_port     = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips      = ["0.0.0.0/0"]
}

#=============== Security Group for Instance ===============

resource "aws_security_group" "instance" {
  name        = "WebServer Security Group"
  description = "My First SecurityGroup by Terraform"
}

resource "aws_security_group_rule" "allow_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.instance.id
  from_port         = var.server_port
  to_port           = var.server_port
  protocol          = local.tcp_protocol
  cidr_blocks       = local.all_ips
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.instance.id
  from_port         = local.any_port
  to_port           = local.any_port
  protocol          = local.any_protocol
  cidr_blocks       = local.all_ips
}

#=========== Launch Configuration ===============

resource "aws_launch_configuration" "example" {
  image_id        = var.ami
  instance_type   = var.instance_type
  security_groups = [aws_security_group.instance.id]
  user_data       = var.user_data
  lifecycle {
    create_before_destroy = true
  }
}

#========== Autoscaling group ===============

resource "aws_autoscaling_group" "example" {
  # Создаем явную зависимость от имени конфигурации запуска,
  # чтобы вместе с ней заменялась и группа ASG
  name                 = "${var.cluster_name}-${aws_launch_configuration.example.name}"
  launch_configuration = aws_launch_configuration.example.name
  vpc_zone_identifier  = var.subnet_ids
  target_group_arns    = var.target_group_arns
  health_check_type    = var.health_check_type
  min_size             = var.min_size
  max_size             = var.max_size
  # Ждем, пока проверку работоспособности не пройдет как минимум
  # столько серверов, прежде чем считать завершенным развертывание ASG
  min_elb_capacity = var.min_size
  # При замене этой группы ASG сначала создаем ее новую версию
  # и только потом удаляем старую
  lifecycle {
    create_before_destroy = true
  }
  tag {
    key                 = "Name"
    value               = var.cluster_name
    propagate_at_launch = true
  }
  dynamic "tag" {
    for_each = {
      for key, value in var.custom_tags :
      key => upper(value)
      if key != "Name"
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  count                  = var.enable_autoscaling ? 1 : 0
  scheduled_action_name  = "${var.cluster_name}-scale-out-during-business-hours"
  min_size               = 2
  max_size               = 10
  desired_capacity       = 10
  recurrence             = "0 9 * * *"
  autoscaling_group_name = aws_autoscaling_group.example.name
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
  count                  = var.enable_autoscaling ? 1 : 0
  scheduled_action_name  = "${var.cluster_name}-scale-in-at-night"
  min_size               = 2
  max_size               = 10
  desired_capacity       = 2
  recurrence             = "0 17 * * *"
  autoscaling_group_name = aws_autoscaling_group.example.name
}

#========== CloudWatch ===============

resource "aws_cloudwatch_metric_alarm" "high_cpu_utilization" {
  alarm_name  = "${var.cluster_name}-high-cpu-utilization"
  namespace   = "AWS/EC2"
  metric_name = "CPUUtilization"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.example.name
  }
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period              = 300
  statistic           = "Average"
  threshold           = 90
  unit                = "Percent"
}

resource "aws_cloudwatch_metric_alarm" "low_cpu_credit_balance" {
  count       = format("%.1s", var.instance_type) == "t" ? 1 : 0
  alarm_name  = "${var.cluster_name}-low-cpu-credit-balance"
  namespace   = "AWS/EC2"
  metric_name = "CPUCreditBalance"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.example.name
  }
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  period              = 300
  statistic           = "Minimum"
  threshold           = 10
  unit                = "Count"
}
