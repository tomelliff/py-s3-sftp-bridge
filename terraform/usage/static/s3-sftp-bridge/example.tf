###################################################################################################

variable "aws_account_id" {}
variable "integration_name" {}

variable "ssh_key_path" {}
variable "ssh_key_file" {}

variable "sftp_host" {}
variable "sftp_port" {}
variable "sftp_user" {}
variable "sftp_location" {}

###################################################################################################

module "s3-sftp-bridge" {
  source                       = "../../../modules/s3-sftp-bridge_lambda"
  integration_name             = "${var.integration_name}"
  lambda_function_package_path = "../../../../s3-sftp-bridge.zip"
  aws_account_id               = "${var.aws_account_id}"

  ssh_key_path = "${var.ssh_key_path}"
  ssh_key_file = "${var.ssh_key_file}"

  sftp_host       = "${var.sftp_host}"
  sftp_port       = "${var.sftp_port}"
  sftp_user       = "${var.sftp_user}"
  sftp_location   = "${var.sftp_location}"
}

###################################################################################################
