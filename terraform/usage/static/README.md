## Static Terraform example

### Environment variable configuration

You'll need to export the following environment variables first:

```sh
export AWS_DEFAULT_REGION='region-name-here' # eg. 'eu-west-1'
export INTEGRATION_NAME='example'
export SSH_KEY_PATH='path/to/ssh_key'
export TF_VAR_aws_account_id=`aws sts get-caller-identity --output text --query 'Account'` # fetch the account ID

```

### SFTP configuration

Simply overwrite the example configuration in `terraform.tfvars`.

### Remote state

The provided `Makefile` configures state for this function to be stored in an S3 bucket using the namespace `tfstate-lambda-functions-$(AWS_ACCOUNT_ID)`. If this doesn't already exist in your account then you can use the `make bootstrap` target to create the bucket. State is stored separately for each different integration the function is created for.

### Building the Lambda function (and supporting bits)

- Run `make plan` to see Terraform's plan for what it wants to build.
- Run `make apply` to actually build the Lambda function and supporting infrastructure
- Finally, run `make destroy` to tear down the Lambda function and supporting infrastructure

### SSH key

Run `make upload_ssh_key` after applying Terraform to upload your SSH key to the SFTP Keys bucket with KMS encryption using the key created.
