#========== Version ===========
#
# terraform {
#
#   # Требуем исключительно версию Terraform 1.1.6
#
#   required_version = "= 1.1.6"
#
# }

#======= Generate Password for DB ===============================
resource "random_string" "rds_password" {
  length           = 12
  special          = true
  override_special = "!@#$%"
  keepers = { # if it's parameter was change, resourse was be recreate
    keeper1 = var.db_password
  }
}

resource "aws_ssm_parameter" "rds_password" {
  name        = var.password_name_db
  description = "Master Password for RDS MySQL"
  type        = "SecureString"
  value       = random_string.rds_password.result
}

data "aws_ssm_parameter" "db_password" {
  name       = var.password_name_db
  depends_on = [aws_ssm_parameter.rds_password]
}

#===================== Data Base =====================================

resource "aws_db_instance" "example" {
  identifier_prefix   = "${var.name_db}-terraform-up-and-running"
  engine              = "mysql"
  allocated_storage   = var.storage
  instance_class      = var.type_db
  db_name             = "${var.name_db}_database"
  username            = var.username_db
  password            = data.aws_ssm_parameter.db_password.value
  skip_final_snapshot = true
}
