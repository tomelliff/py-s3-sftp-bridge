###################################################################################################

variable "aws_account_id" {}
variable "integration_name" {}

variable "sftp_host" {}
variable "sftp_port" {}
variable "sftp_user" {}
variable "sftp_location" {}
variable "sftp_s3_ssh_key" {}

###################################################################################################

module "s3-sftp-bridge" {
  source                       = "../../modules/s3-sftp-bridge_lambda"
  integration_name             = "${var.integration_name}"
  lambda_function_package_path = "../../../s3-sftp-bridge.zip"
  aws_account_id               = "${var.aws_account_id}"

  sftp_host       = "${var.sftp_host}"
  sftp_port       = "${var.sftp_port}"
  sftp_user       = "${var.sftp_user}"
  sftp_location   = "${var.sftp_location}"
  sftp_s3_ssh_key = "${var.sftp_s3_ssh_key}"
}

###################################################################################################

output "kms_key_id" {
  value = "${module.s3-sftp-bridge.kms_key_id}"
}

output "sftp_keys_bucket" {
  value = "${module.s3-sftp-bridge.sftp_keys_bucket}"
}

###################################################################################################
