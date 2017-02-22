# S3 SFTP Bridge

A Python Lambda function that syncs files between Amazon S3 and external FTP servers. For S3 => SFTP, it will automatically sync when objects are uploaded to S3.

Heavily inspired by [@Gilt](https://github.com/gilt)'s Node.js implementation of [s3-sftp-bridge](https://github.com/gilt/s3-sftp-bridge)

---

Note that `pysftp` relies on `Cryptography` which must be compiled on the target platform. As AWS Lambda runs on Amazon Linux then `pip install pysftp` must be ran on an Amazon Linux instance for the packaged dependencies to be valid. Right now I'm just grabbing some pre-compiled binaries from S3 that I built with the following commands:

```sh
sudo yum install python-virtualenv gcc libffi-devel python-devel openssl-devel
virtualenv env
. env/bin/activate
pip install cryptography
cd env/lib/python2.7/site-packages/
zip -r9 ../../../../py-cryptography-1.7.2.zip *
cd -
cd env/lib64/python2.7/site-packages/
zip -r9 ../../../../py-cryptography-1.7.2.zip *
```

---

## Requirements

* Python 2.7

## Building it

### Just build the Lambda zip
```sh
make build
```

### Create an S3 bucket to store the Lambda function
```sh
make create_deploy_bucket
```

### Shipping the packaged Lambda function
```sh
make ship
```

## Running it locally

### Local setup/configuration

Make sure you have AWS credentials configured and a default region specified.

This can be with environment variables:

```sh
export AWS_ACCESS_KEY_ID=<my-access-key>
export AWS_SECRET_ACCESS_KEY=<my-secret-key>
export AWS_DEFAULT_REGION=<my-default-region>
```

or setting them in either an AWS credentials file (~/.aws/credentials) or AWS config file (~/.aws/config):

```
[default]
aws_access_key_id = <my-access-key>
aws_secret_access_key = <my-secret-key>
region = <my-default-region>
```

You will also need to provide credentials for the SFTP server:

```sh
export SFTP_HOST='sftp.example.com'
export SFTP_PORT='2222'
export SFTP_USER='user'
export SFTP_S3_SSH_KEY='my_ssh_keys_bucket/my_ssh_key.pem'
export SFTP_LOCATION='share'
```

### Virtualenv/dependencies

```sh
virtualenv env
. env/bin/activate
pip install -r requirements.txt
```

### Run it

```sh
python s3-sftp-bridge.py my_bucket/path/to/object
```

## TODO

- Write Tests
- Handle failures - Write event to SQS, non S3 PUT event triggers cause the queue to be polled and messages retried
- SFTP -> S3 transfers - non S3 PUT events poll the SFTP server for completed files and then writes them to S3
- Cloudformation and/or Terraform to deploy Lambda function and dependencies
  - Create CloudFormation "Launch Stack" buttons (?)
