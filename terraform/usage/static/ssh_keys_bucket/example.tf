###################################################################################################

variable "aws_account_id" {}

module "s3-sftp-bridge" {
  source = "github.com/tomelliff/py-s3-sftp-bridge//terraform/modules/s3-sftp-bridge_ssh-keys-bucket?refs=terraform-v1"
}

###################################################################################################
