###################################################################################################

resource "aws_lambda_permission" "allow_scheduled_event" {
  statement_id  = "AllowExecutionFromScheduledEvent"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.s3_sftp_bridge_lambda.arn}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.trigger_retry.arn}"
}

resource "aws_cloudwatch_event_rule" "trigger_retry" {
  name                = "${var.function_prefix}-${var.integration_name}"
  description         = "${var.retry_scheduled_event_description}"
  schedule_expression = "${var.retry_schedule_expression}"
}

resource "aws_cloudwatch_event_target" "s3_sftp_bridge_lambda" {
  rule      = "${aws_cloudwatch_event_rule.trigger_retry.name}"
  arn       = "${aws_lambda_function.s3_sftp_bridge_lambda.arn}"
  target_id = "S3SftpBridge"
}

###################################################################################################
