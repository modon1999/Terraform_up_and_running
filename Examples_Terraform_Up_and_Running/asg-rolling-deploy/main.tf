#================== Provider ================
provider "aws" {
  region = "eu-central-1"
}

#=============== State ===============

terraform {
  backend "s3" {
    # Поменяйте это на имя своего бакета!
    bucket = "modon-terraform-up-and-running-state"
    key    = "examples/asg-rolling-deploy/terraform.tfstate"
    region = "eu-central-1"
    # Замените это именем своей таблицы DynamoDB!
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }
}

#=============== Data ===============

data "aws_availability_zones" "available" {}
data "aws_vpc" "default" {
  # Data about default vpc
  default = true
}

resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available.names[0]
}


resource "aws_default_subnet" "default_az2" {
  availability_zone = data.aws_availability_zones.available.names[1]
}

#================== Modules ================

module "asg" {
  source             = "github.com/modon1999/Modules_Terraform_Up_and_Running//cluster/asg-rolling-deploy?ref=v0.0.7"
  cluster_name       = var.cluster_name
  ami                = "ami-0f61af304b14f15fb"
  instance_type      = "t2.micro"
  min_size           = 1
  max_size           = 1
  enable_autoscaling = false
  subnet_ids         = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
  user_data          = <<EOF
  #!bin/bash
  yum -y update
  yum -y install httpd
  PrivateIP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
  echo "<html><body bgcolor=blue><center><h2><p><font color=red>Web Server with: $PrivateIP Build by Terraform!</h2></center></body></html>" > /var/www/html/index.html
  sudo service httpd start
  chkconfig httpd on
EOF
}
