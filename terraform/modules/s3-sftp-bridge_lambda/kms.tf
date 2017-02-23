###################################################################################################

resource "aws_kms_key" "configuration_key" {
  description = "${var.function_prefix}-${var.integration_name}"
}

resource "aws_kms_alias" "configuration_key" {
  name          = "alias/${var.function_prefix}-${var.integration_name}"
  target_key_id = "${aws_kms_key.configuration_key.key_id}"
}

###################################################################################################

output "kms_key_id" {
  value = "${aws_kms_key.configuration_key.key_id}"
}

###################################################################################################

