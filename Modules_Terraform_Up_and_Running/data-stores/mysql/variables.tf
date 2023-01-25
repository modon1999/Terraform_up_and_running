variable "db_password" {
  description = "The password for the database"
  type        = string
  default     = "1"
}

variable "password_name_db" {
  description = "The name for the database"
  type        = string
  default     = "/example"
}

variable "name_db" {
  description = "The name for the database"
  type        = string
  default     = "example"
}

variable "type_db" {
  description = "The name for the database"
  type        = string
  default     = "db.t2.micro"
}

variable "storage" {
  description = "The name for the database"
  type        = string
  default     = "10"
}

variable "username_db" {
  description = "The name for the database"
  type        = string
  default     = "admin"
}
