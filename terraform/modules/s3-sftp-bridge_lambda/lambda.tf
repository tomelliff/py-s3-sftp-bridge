###################################################################################################

resource "aws_lambda_function" "s3_sftp_bridge_lambda" {
  filename         = "${var.lambda_function_package_path}"
  function_name    = "${var.function_prefix}-${var.integration_name}"
  description      = "${var.lambda_description}"
  runtime          = "python2.7"
  role             = "${aws_iam_role.lambda_role.arn}"
  handler          = "s3_sftp_bridge.handler"
  source_code_hash = "${base64sha256(file("${var.lambda_function_package_path}"))}"
  timeout          = 60

  environment {
    variables = {
      QUEUE_NAME      = "${aws_sqs_queue.dead_letter.name}"
      SFTP_HOST       = "${var.sftp_host}"
      SFTP_PORT       = "${var.sftp_port}"
      SFTP_USER       = "${var.sftp_user}"
      SFTP_LOCATION   = "${var.sftp_location}"
      SFTP_S3_SSH_KEY = "s3-sftp-bridge-ssh-keys-${var.aws_account_id}/${var.integration_name}/${var.ssh_key_file}"
    }
  }
}

###################################################################################################
