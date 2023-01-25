#================== Provider ================
provider "aws" {
  region = "eu-central-1"
}

#=============== State ===============

terraform {
  backend "s3" {
    # Поменяйте это на имя своего бакета!
    bucket = "modon-terraform-up-and-running-state"
    key    = "examples/alb/terraform.tfstate"
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

module "alb" {
  source   = "github.com/modon1999/Modules_Terraform_Up_and_Running//networking/alb?ref=v0.0.7"
  subnets  = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
  alb_name = "example"
}
