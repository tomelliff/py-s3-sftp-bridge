SOURCES=s3_sftp_bridge.py
DEPENDENCIES=requirements.txt
VENDORED_FOLDER=vendored
VIRTUAL_ENV=env
PACKAGE_NAME=s3-sftp-bridge.zip
DEPLOY_BUCKET_NAME=lambda-functions-$(AWS_DEFAULT_REGION)-$(AWS_ACCOUNT_ID)

.PHONY: all
all: docker

$(VENDORED_FOLDER): $(DEPENDENCIES)
	pip install -r $(DEPENDENCIES) -t $(VENDORED_FOLDER)

$(PACKAGE_NAME): $(SOURCES) $(VENDORED_FOLDER)
	zip -r $(PACKAGE_NAME) $(SOURCES) $(VENDORED_FOLDER)

.PHONY: build
build: $(PACKAGE_NAME)

.PHONY: docker
docker: test Dockerfile
	docker run --rm \
	-v $(shell pwd):/root \
	$(shell docker build -q .)

$(VIRTUAL_ENV):
	virtualenv $(VIRTUAL_ENV); \

.PHONY: test
test: $(VIRTUAL_ENV)
	. env/bin/activate; \
	pip install -r requirements-dev.txt; \
	python -m unittest discover; \
	flake8 --exclude .git,*.pyc,env,vendored,terraform

.PHONY: clean
clean:
	rm -f $(PACKAGE_NAME)
	rm -rf $(VENDORED_FOLDER)

.PHONY: create_deploy_bucket
create_deploy_bucket:
	region_constraints='--region $(AWS_DEFAULT_REGION) --create-bucket-configuration LocationConstraint=$(AWS_DEFAULT_REGION)'; \
	aws s3api create-bucket --bucket $(DEPLOY_BUCKET_NAME) $${region_constraints}

.PHONY: ship
ship: docker
	aws_account_id=`aws sts get-caller-identity --output text --query Account`; \
	aws s3 cp $(PACKAGE_NAME) s3://$(DEPLOY_BUCKET_NAME)
