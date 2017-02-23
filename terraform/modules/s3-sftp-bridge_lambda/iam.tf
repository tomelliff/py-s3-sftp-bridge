###################################################################################################

resource "aws_iam_role" "lambda_role" {
  name = "${var.function_prefix}-${var.integration_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda_s3_access" {
  role = "${aws_iam_role.lambda_role.id}"
  name = "s3_access"

  policy = <<EOF
{
  "Version"  : "2012-10-17",
  "Statement": [
    {
      "Sid"     :   "1",
      "Effect"  :   "Allow",

      "Action"  : [ "s3:CopyObject",
                    "s3:GetObject",
                    "s3:ListObjects",
                    "s3:PutObject" ],
      "Resource": [ "arn:aws:s3:::${aws_s3_bucket.event_bucket.bucket}",
                    "arn:aws:s3:::${aws_s3_bucket.event_bucket.bucket}/*",
                    "arn:aws:s3:::${aws_s3_bucket.sftp_keys.bucket}",
                    "arn:aws:s3:::${aws_s3_bucket.sftp_keys.bucket}/*" ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda_logging" {
  role = "${aws_iam_role.lambda_role.id}"
  name = "logging"

  policy = <<EOF
{
  "Version"  : "2012-10-17",
  "Statement": [
    {
      "Sid"     :   "1",
      "Effect"  :   "Allow",

      "Action"  : [ "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents" ],
      "Resource":   "arn:aws:logs:*:*:*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda_kms" {
  role = "${aws_iam_role.lambda_role.id}"
  name = "kms"

  policy = <<EOF
{
  "Version"  : "2012-10-17",
  "Statement": [
    {
      "Sid"     :   "1",
      "Effect"  :   "Allow",

      "Action"  :   "kms:Decrypt",
      "Resource":   "${aws_kms_key.configuration_key.arn}"
    }
  ]
}
EOF
}

###################################################################################################

