DIST_DIR=./dst
destroy:
	terraform destroy terraform

deploy: build-lambda
	terraform apply terraform

build-lambda:
	rm -rf $(DIST_DIR)
	mkdir $(DIST_DIR)
	docker build --file=./Lambda.Dockerfile --tag group_text ./
	docker run --volume="${PWD}/$(DIST_DIR):/deploy" group_text cp lambda.zip /deploy/lambda.zip