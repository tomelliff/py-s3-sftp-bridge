import json
import unittest

from mock import patch, mock_open

import s3_sftp_bridge

class TestHandler(unittest.TestCase):
    # Taken from Lambda's test S3 PUT event
    s3_put_event = json.loads("""{
  "Records": [
    {
      "eventVersion": "2.0",
      "eventTime": "1970-01-01T00:00:00.000Z",
      "requestParameters": {
        "sourceIPAddress": "127.0.0.1"
      },
      "s3": {
        "configurationId": "testConfigRule",
        "object": {
          "eTag": "0123456789abcdef0123456789abcdef",
          "sequencer": "0A1B2C3D4E5F678901",
          "key": "HappyFace.jpg",
          "size": 1024
        },
        "bucket": {
          "arn": "arn:aws:s3:::mybucket",
          "name": "sourcebucket",
          "ownerIdentity": {
            "principalId": "EXAMPLE"
          }
        },
        "s3SchemaVersion": "1.0"
      },
      "responseElements": {
        "x-amz-id-2": "EXAMPLE123/5678abcdefghijklambdaisawesome/mnopqrstuvwxyzABCDEFGH",
        "x-amz-request-id": "EXAMPLE123456789"
      },
      "awsRegion": "us-east-1",
      "eventName": "ObjectCreated:Put",
      "userIdentity": {
        "principalId": "EXAMPLE"
      },
      "eventSource": "aws:s3"
    }
  ]
}""")

    # Taken from Lambda's test scheuled event
    scheduled_event = json.loads("""{
  "account": "123456789012",
  "region": "us-east-1",
  "detail": {},
  "detail-type": "Scheduled Event",
  "source": "aws.events",
  "time": "1970-01-01T00:00:00Z",
  "id": "cdc73f9d-aea9-11e3-9d5a-835b769c0d9c",
  "resources": [
    "arn:aws:events:us-east-1:123456789012:rule/my-schedule"
  ]
}""")

    @patch('s3_sftp_bridge.new_s3_object')
    def test_handler_accepts_s3_put_event(self, mock_new_object):
        s3_sftp_bridge.handler(self.s3_put_event, 'context')
        mock_new_object.assert_called_once_with('sourcebucket', 'HappyFace.jpg')

    @patch('s3_sftp_bridge.retry_failed_messages')
    def test_handler_retries_failed_on_non_s3_put_events(self, mock_retry):
        s3_sftp_bridge.handler(self.scheduled_event, 'context')
        mock_retry.assert_called_once_with()

    @patch('s3_sftp_bridge.new_s3_object')
    def test_handler_returns_200_response(self, mock_new_object):
        response = s3_sftp_bridge.handler(self.s3_put_event, 'context')
        self.assertEqual(response['statusCode'], 200)
        self.assertEqual(response['body'], 'Uploaded HappyFace.jpg')


if __name__ == '__main__':
    unittest.main()
