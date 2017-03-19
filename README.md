# S3 SFTP Bridge

[![Build Status](https://travis-ci.org/tomelliff/py-s3-sftp-bridge.svg?branch=master)](https://travis-ci.org/tomelliff/py-s3-sftp-bridge)
[![Coverage Status](https://coveralls.io/repos/github/tomelliff/py-s3-sftp-bridge/badge.svg?branch=master)](https://coveralls.io/github/tomelliff/py-s3-sftp-bridge?branch=master)

A Python Lambda function that syncs files between Amazon S3 and external SFTP servers. As objects are uploaded to S3 they will be automatically copied to an SFTP server.

In the event of failure such as connecting to the SFTP server AWS Lambda will automatically retry twice and then move on to the configurable dead letter handling. If this is configured to use an SQS queue (provided by the Terraform module) then a non S3 PUT event trigger of the Lambda function will then attempt to pull failed events from the configured SQS queue (provided by the `QUEUE_NAME` environment variable).

---

Heavily inspired by [@Gilt](https://github.com/gilt)'s Node.js implementation of [s3-sftp-bridge](https://github.com/gilt/s3-sftp-bridge)

This implementation mostly differs from Gilt's in that it takes a deliberate decision that each separate integration should be deployed as a separate Lambda function (and all the surrounding stuff such as the event bucket, SQS queue for dead letter handling, scheduled event etc). This simplifies the deployment model greatly and sticks to on of my key principles of decentralisation over shared services.

---

Note that [`pysftp`](https://pypi.python.org/pypi/pysftp) relies on [`Cryptography`](https://pypi.python.org/pypi/cryptography) which must be compiled on the target platform. As AWS Lambda runs on Amazon Linux then `pip install pysftp` must be ran on an Amazon Linux instance for the packaged dependencies to be valid. Right now I'm just grabbing some pre-compiled binaries from S3 that I built with the following commands:

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

## SFTP Authentication

Right now the Lambda function only supports public key authentication but could be made to support password based authentication as well.

While a typical 4096 bit RSA key will just about fit inside the (4KB limit)[http://docs.aws.amazon.com/lambda/latest/dg/limits.html#limits-troubleshooting] for AWS Lambda environment variables this leaves it readable in plaintext to anyone with read access to the Lambda function. If the key is instead KMS encrypted and used then, from my limited testing, it now exceeds the 4KB limit.

As such this Lambda function currently expects an SSH private key to be held in an S3 bucket where access can be restricted via IAM/bucket policies and/or KMS encryption.

If it becomes possible to directly support a KMS encrypted private key directly in the AWS Lambda environment variables then I'll try to rework things to do so.

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
python s3_sftp_bridge.py my_bucket/path/to/object
```

## Deploying

### Terraform

This repo provides a [Terraform module](https://github.com/tomelliff/py-s3-sftp-bridge/tree/master/terraform/modules) that will deploy and configure the Lambda function and supporting infrastructure.

There is a small example of how to use the Terraform module under [`terraform/usage/static/`](https://github.com/tomelliff/py-s3-sftp-bridge/tree/master/terraform/usage/static).

## TODO

- Write more tests (coverage shown by Coveralls.io)
- Support automatic DLQ handling in [Terraform 0.9](https://github.com/hashicorp/terraform/pull/12188)
- Use Amazon Linux Docker container to build the Lambda package and avoid having to pull Cryptography from S3
- Support password based SFTP authentication
- SFTP -> S3 transfers - non S3 PUT events poll the SFTP server for completed files and then writes them to S3 (separate project/repo?)
- Cloudformation to deploy Lambda function and dependencies
  - Create CloudFormation "Launch Stack" buttons (?)
