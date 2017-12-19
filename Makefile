PWD=$(shell pwd)
build:
	docker build -t indaco/ecapp .
run: build stop
	docker run --name ecapp-instance \
  -p 9000:9000 \
  -v predix-ec-configurator:/go/src/github.com/indaco/ecapp \
  -d -it indaco/ecapp
stop:
	docker rm -f ecapp-instance || true
