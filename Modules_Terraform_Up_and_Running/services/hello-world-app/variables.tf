variable "environment" {
  description = "The name of the environment we're deploying to"
  type        = string
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 80
}

variable "instance_type" {
  description = "The type of EC2 Instances to run (e.g. t2.micro)"
  type        = string
}

variable "min_size" {
  description = "The minimum number of EC2 Instances in the ASG"
  type        = number
}

variable "max_size" {
  description = "The maximum number of EC2 Instances in the ASG"
  type        = number
}

variable "custom_tags" {
  description = "Custom tags to set on the Instances in the ASG"
  type        = map(string)
  default     = {}
}

variable "enable_autoscaling" {
  description = "If set to true, enable auto scaling"
  type        = bool
  default     = false
}

variable "ami" {
  description = "The AMI to run in the cluster"
  default     = "ami-0f61af304b14f15fb"
  type        = string
}

variable "server_text" {
  description = "The text the web server should return"
  default     = "Hello, Nikita!!!"
  type        = string
}

variable "subnet_ids" {
  description = "The subnet IDs to deploy to"
  type        = list(string)
}

variable "health_check_type" {
  description = "The type of health check to perform. Must be one of: EC2, ELB."
  type        = string
  default     = "EC2"
}

variable "vpc_id" {
  description = "The type of health check to perform. Must be one of: EC2, ELB."
  type        = string
}

variable "db_remote_state_bucket" {
  description = "The name for the database"
  type        = string
}

variable "db_remote_state_key" {
  description = "The name for the database"
  type        = string
}
