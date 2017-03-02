AWS_ACCOUNT_ID=`aws sts get-caller-identity --output text --query 'Account'`

ifndef AWS_DEFAULT_REGION
    $(error AWS_DEFAULT_REGION is not set)
endif

bootstrap:
	region_constraints='--region $(AWS_DEFAULT_REGION) --create-bucket-configuration LocationConstraint=$(AWS_DEFAULT_REGION)'; \
	aws s3api create-bucket --bucket tfstate-lambda-functions-$(AWS_ACCOUNT_ID) $${region_constraints}

remote:
	terraform remote config -backend="S3" \
				-backend-config="bucket=tfstate-lambda-functions-$(AWS_ACCOUNT_ID)" \
				-backend-config="key=s3-sftp-bridge-$(INTEGRATION_NAME)/state"

get:
	terraform get -update=true

plan: get remote
	terraform plan -input=false

apply: get remote
	terraform apply -input=false

destroy: get remote
	terraform destroy -input=false -force
