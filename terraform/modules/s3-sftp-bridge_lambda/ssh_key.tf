###################################################################################################

resource "aws_s3_bucket_object" "ssh_key" {
  key        = "${var.integration_name}/${var.ssh_key_file}"
  bucket     = "s3-sftp-bridge-ssh-keys-${data.aws_caller_identity.current.account_id}"
  source     = "${var.ssh_key_path}/${var.ssh_key_file}"
  kms_key_id = "${aws_kms_key.configuration_key.arn}"
}

###################################################################################################
