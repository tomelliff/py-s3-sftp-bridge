###################################################################################################

variable "aws_account_id" {}

###################################################################################################

variable "s3_keys_versioning" {
  default = "true"
}

###################################################################################################

resource "aws_s3_bucket" "ssh_keys" {
  bucket = "s3-sftp-bridge-ssh-keys-${var.aws_account_id}"

  policy = <<EOF
{
  "Version":"2012-10-17",
  "Id":"PutObjPolicy",
  "Statement":[
    {
      "Sid": "DenyIncorrectEncryptionHeader",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::s3-sftp-bridge-ssh-keys-${var.aws_account_id}/*",
      "Condition": {
        "StringNotEquals": {
          "s3:x-amz-server-side-encryption": "aws:kms"
        }
      }
    }
  ]
}
EOF

  versioning {
    enabled = "${var.s3_keys_versioning}"
  }

  tags {
    Name = "s3-sftp-bridge-ssh-keys-${var.aws_account_id}"
  }
}

###################################################################################################

output "sftp_keys_bucket" {
  value = "${aws_s3_bucket.ssh_keys.bucket}"
}

###################################################################################################
