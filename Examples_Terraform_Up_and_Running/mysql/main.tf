#================== Provider ================
provider "aws" {
  region = "eu-central-1"
}

#=============== State ===============

terraform {
  backend "s3" {
    # Поменяйте это на имя своего бакета!
    bucket = "modon-terraform-up-and-running-state"
    key    = "examples/mysql/terraform.tfstate"
    region = "eu-central-1"
    # Замените это именем своей таблицы DynamoDB!
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }
}

#================== Modules ================

module "mysql" {
  source           = "github.com/modon1999/Modules_Terraform_Up_and_Running//data-stores/mysql?ref=v0.0.7"
  password_name_db = "/example"
  name_db          = "example"
  type_db          = "db.t2.micro"
  storage          = 10
  username_db      = "admin"
}
