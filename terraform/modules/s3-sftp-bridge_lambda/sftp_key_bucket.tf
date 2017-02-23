###################################################################################################

variable "s3_keys_versioning" {
  default = "true"
}

###################################################################################################

resource "aws_s3_bucket" "sftp_keys" {
  bucket = "${var.function_prefix}-sftp-keys-${var.integration_name}-${var.aws_account_id}"

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
      "Resource": "arn:aws:s3:::${var.function_prefix}-sftp-keys-${var.integration_name}-${var.aws_account_id}/*",
      "Condition": {
        "StringNotEquals": {
          "s3:x-amz-server-side-encryption": "aws:kms"
        }
      }
    },
    {
      "Sid":"DenyUnEncryptedObjectUploads",
      "Effect":"Deny",
      "Principal":"*",
      "Action":"s3:PutObject",
      "Resource":"arn:aws:s3:::${var.function_prefix}-sftp-keys-${var.integration_name}-${var.aws_account_id}/*",
      "Condition":{
        "StringNotEquals":{
          "s3:x-amz-server-side-encryption-aws-kms-key-id":"${aws_kms_key.configuration_key.arn}"
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
    Name = "${var.function_prefix}-sftp-keys-${var.integration_name}-${var.aws_account_id}"
  }
}

###################################################################################################

output "sftp_keys_bucket" {
  value = "${aws_s3_bucket.sftp_keys.bucket}"
}

###################################################################################################

