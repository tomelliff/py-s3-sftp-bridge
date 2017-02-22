SOURCES=s3-sftp-bridge.py
DEPENDENCIES=requirements.txt
COMPILED_DEPENDENCIES=py-cryptography-1.7.2.zip
VENDORED_FOLDER=vendored
PACKAGE_NAME=s3-sftp-bridge.zip
DEPLOY_BUCKET_NAME=lambda-functions-$(AWS_DEFAULT_REGION)-$(AWS_ACCOUNT_ID)

$(COMPILED_DEPENDENCIES):
	curl --silent https://s3-eu-west-1.amazonaws.com/amazon-compiled-python-modules/$(COMPILED_DEPENDENCIES) -o $(COMPILED_DEPENDENCIES)
	unzip -d $(VENDORED_FOLDER) $(COMPILED_DEPENDENCIES)

$(VENDORED_FOLDER): $(COMPILED_DEPENDENCIES) $(DEPENDENCIES)
	pip install -r $(DEPENDENCIES) -t $(VENDORED_FOLDER)

$(PACKAGE_NAME): $(SOURCES) $(VENDORED_FOLDER)
	zip -r $(PACKAGE_NAME) $(SOURCES) $(VENDORED_FOLDER)

build: test $(PACKAGE_NAME)

test:
	python -m unittest discover

create_deploy_bucket:
	region_constraints='--region $(AWS_DEFAULT_REGION) --create-bucket-configuration LocationConstraint=$(AWS_DEFAULT_REGION)'; \
	aws s3api create-bucket --bucket $(DEPLOY_BUCKET_NAME) $${region_constraints}

ship: build
	aws_account_id=`aws sts get-caller-identity --output text --query Account`; \
	aws s3 cp $(PACKAGE_NAME) s3://$(DEPLOY_BUCKET_NAME)
