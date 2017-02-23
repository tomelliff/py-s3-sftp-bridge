###################################################################################################

variable "function_prefix" {
  default = "s3-sftp-bridge"
}

###################################################################################################

variable "integration_name" {}
variable "lambda_function_package_path" {}

variable "lambda_description" {
  default = "Managed by Terraform"
}

###################################################################################################

variable "sftp_host" {}
variable "sftp_user" {}
variable "sftp_location" {}
variable "sftp_s3_ssh_key" {}

variable "sftp_port" {
  default = "22"
}

###################################################################################################

resource "aws_lambda_function" "s3_sftp_bridge_lambda" {
  filename         = "${var.lambda_function_package_path}"
  function_name    = "${var.function_prefix}-${var.integration_name}"
  description      = "${var.lambda_description}"
  runtime          = "python2.7"
  role             = "${aws_iam_role.lambda_role.arn}"
  handler          = "s3-sftp-bridge.handler"
  source_code_hash = "${base64sha256(file("${var.lambda_function_package_path}"))}"
  timeout          = 60

  environment {
    variables = {
      SFTP_HOST       = "${var.sftp_host}"
      SFTP_PORT       = "${var.sftp_port}"
      SFTP_USER       = "${var.sftp_user}"
      SFTP_LOCATION   = "${var.sftp_location}"
      SFTP_S3_SSH_KEY = "${aws_s3_bucket.sftp_keys.bucket}/${var.sftp_s3_ssh_key}"
    }
  }
}

###################################################################################################

