#=============== Provider ===============

provider "aws" {
  region = "eu-central-1"
}

#=============== State ===============

terraform {
  backend "s3" {
    # Поменяйте это на имя своего бакета!
    bucket = "modon-terraform-up-and-running-state"
    key    = "prod/services/webserver-cluster/terraform.tfstate"
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

#=============== Module =============

module "hello-world-app" {
  source                 = "github.com/modon1999/Modules_Terraform_Up_and_Running//services/hello-world-app?ref=v0.0.7"
  subnet_ids             = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
  environment            = "prod"
  vpc_id                 = data.aws_vpc.default.id
  server_port            = 80
  ami                    = "ami-0f61af304b14f15fb"
  instance_type          = "t2.micro"
  min_size               = 1
  max_size               = 1
  enable_autoscaling     = false
  db_remote_state_bucket = "modon-terraform-up-and-running-state"
  db_remote_state_key    = "prod/data-stores/mysql/terraform.tfstate"
  custom_tags = {
    name = "EXAMPLE"
  }
  server_text       = "Prod for Nikita!"
  health_check_type = "ELB"
}
