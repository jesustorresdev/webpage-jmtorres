CONTAINER_BIN = podman
CONTAINER_IMAGE_TAG = 0.73.0-ext-nodejs
CONTAINER_IMAGE_NAME = klakegg/hugo
CONTAINER_IMAGE = $(CONTAINER_IMAGE_NAME):$(CONTAINER_IMAGE_TAG)

HUGO_BIN = hugo
SERVER_PORT = 1313

server:
	hugo server

build:
	hugo

docker-server:
	$(CONTAINER_BIN) run --rm -it --volume $(PWD):/src --publish $(SERVER_PORT):1313 $(CONTAINER_IMAGE) docker-server

docker-build:
	$(CONTAINER_BIN) run --rm -it --volume $(PWD):/src $(CONTAINER_IMAGE)

docker-shell:
	$(CONTAINER_BIN) run --rm -it --volume $(PWD):/src --entrypoint /bin/sh $(CONTAINER_IMAGE)

.PHONY: build server docker-build docker-server docker-shell
