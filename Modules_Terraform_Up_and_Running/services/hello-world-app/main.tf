#========== Version ===========

# terraform {
#
#   # Требуем исключительно версию Terraform 1.1.6
#
#   required_version = "= 1.1.6"
#
# }

#==========Local variables ===========

locals {
  http_port    = 80
  any_port     = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips      = ["0.0.0.0/0"]
}

#=============== User Data ===============

data "template_file" "user_data" {
  template = file("${path.module}/user_data.sh.tpl")
  vars = {
    db_address  = data.terraform_remote_state.db.outputs.address
    db_port     = data.terraform_remote_state.db.outputs.port
    server_text = var.server_text
  }
}

#=============== Data Base =================================

data "terraform_remote_state" "db" {
  backend = "s3"
  config = {
    bucket = var.db_remote_state_bucket
    key    = var.db_remote_state_key
    region = "eu-central-1"
  }
}

#========== Target Group ===============

resource "aws_lb_target_group" "asg" {
  name     = "terraform-asg-example"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "asg" {
  listener_arn = module.alb.alb_http_listener_arn
  priority     = 100
  condition {
    path_pattern {
      values = ["*"]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}

#========== Modules ===============

module "asg" {
  source             = "github.com/modon1999/Modules_Terraform_Up_and_Running//cluster/asg-rolling-deploy?ref=v0.0.7"
  cluster_name       = "hello-world-${var.environment}"
  server_port        = var.server_port
  ami                = var.ami
  user_data          = data.template_file.user_data.rendered
  instance_type      = var.instance_type
  min_size           = var.min_size
  max_size           = var.max_size
  enable_autoscaling = var.enable_autoscaling
  subnet_ids         = var.subnet_ids
  target_group_arns  = [aws_lb_target_group.asg.arn]
  health_check_type  = "ELB"
  custom_tags        = var.custom_tags
}

module "alb" {
  source   = "github.com/modon1999/Modules_Terraform_Up_and_Running//networking/alb?ref=v0.0.7"
  alb_name = "hello-world-${var.environment}"
  subnets  = var.subnet_ids
}
