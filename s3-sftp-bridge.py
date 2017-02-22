from __future__ import print_function
import argparse
import os
import sys

here = os.path.dirname(os.path.realpath(__file__))
sys.path.append(os.path.join(here, "vendored"))

import boto3
from botocore.exceptions import ClientError
import pysftp

tmp_dir = '/tmp'

def handler(event, context):
    event_record = event['Records'][0]
    if event_record['eventSource'] == "aws:s3":
        s3_event = event_record['s3']
        s3_bucket = s3_event['bucket']['name']
        s3_key = s3_event['object']['key']

        new_s3_object(s3_bucket, s3_key)

        response = {
            "statusCode": 200,
            "body": "Uploaded {}".format(s3_key)
        }

    return response

def new_s3_object(s3_bucket, s3_key):
    try:
        _download_s3_object(s3_bucket, s3_key)
        _upload_file(s3_key)
    except BaseException:
        print('failed to transfer file')
        _handle_failures(s3_bucket, s3_key)
        raise

def _split_s3_path(s3_full_path):
    bucket = s3_full_path.split('/')[0]
    key_path = '/'.join(s3_full_path.split('/')[1:])

    return (bucket, key_path)

def _download_s3_object(s3_bucket, s3_key):
    try:
        s3 = boto3.resource('s3')
        bucket = s3.Bucket(s3_bucket)
        bucket.download_file(s3_key, '{}/{}'.format(tmp_dir, s3_key))
        print('fetched object {}'.format(s3_key))
    except ClientError:
        print('object not found')
        raise


def _upload_file(file_path):
    host = os.environ['SFTP_HOST']
    port = int(os.environ['SFTP_PORT'])
    user = os.environ['SFTP_USER']
    s3_private_key = os.environ['SFTP_S3_SSH_KEY']
    sftp_location = os.environ['SFTP_LOCATION']

    s3_ssh_key_bucket, s3_ssh_key_path =_split_s3_path(s3_private_key)

    _download_s3_object(s3_ssh_key_bucket, s3_ssh_key_path)
    private_key = '{}/{}'.format(tmp_dir, s3_ssh_key_path)

    cnopts = pysftp.CnOpts()
    cnopts.hostkeys = None

    try:
        with pysftp.Connection(host=host, port=port,
                               username=user,
                               private_key=private_key,
                               cnopts=cnopts) as sftp:
            with sftp.cd(sftp_location):
                sftp.makedirs(os.path.dirname(file_path))
                sftp.put('/tmp/{}'.format(file_path), file_path)
                print('uploaded {}'.format(file_path))

    except (pysftp.ConnectionException, pysftp.CredentialException,
            pysftp.SSHException, pysftp.AuthenticationException):
        print('connection error')
        raise

    except IOError:
        print('failed to upload file')
        raise

def _handle_failures(s3_bucket, s3_key):
    # TODO: Put event onto SQS queue to be retried later?
    print('handling failure')
    pass

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
                        description='Move a file from S3 to an SFTP server')
    parser.add_argument('s3_path', help='The full path to the s3 object.\n' \
                        'eg. my_bucket/path/to/key')
    args = parser.parse_args()

    s3_bucket, s3_key = _split_s3_path(args.s3_path)

    new_s3_object(s3_bucket, s3_key)
