###################################################################################################

terraform {
  required_version = ">= 0.9.0"
}

###################################################################################################

variable "integration_name" {}

variable "function_prefix" {
  default = "s3-sftp-bridge"
}

###################################################################################################

variable "ssh_key_path" {}
variable "ssh_key_file" {}

###################################################################################################

variable "lambda_function_package_path" {}

variable "lambda_description" {
  default = "Managed by Terraform"
}

###################################################################################################

variable "sftp_host" {}
variable "sftp_user" {}
variable "sftp_location" {}

variable "sftp_port" {
  default = "22"
}

###################################################################################################

variable "retry_schedule_expression" {
  default = "cron(0/5 * * * ? *)"
}

variable "retry_scheduled_event_description" {
  default = "Managed by Terraform"
}

###################################################################################################
