CONTAINER_BIN = podman
CONTAINER_IMAGE_TAG = 0.73.0-ext-nodejs
CONTAINER_IMAGE_NAME = klakegg/hugo
CONTAINER_IMAGE = $(CONTAINER_IMAGE_NAME):$(CONTAINER_IMAGE_TAG)

HUGO_BIN = hugo
SERVER_PORT = 1313

local-server:
	hugo server --disableFastRender

local-build:
	hugo

server:
	$(CONTAINER_BIN) run --rm -it --volume $(PWD):/src --publish $(SERVER_PORT):1313 $(CONTAINER_IMAGE) container-server

build:
	$(CONTAINER_BIN) run --rm -it --volume $(PWD):/src $(CONTAINER_IMAGE)

shell:
	$(CONTAINER_BIN) run --rm -it --volume $(PWD):/src $(CONTAINER_IMAGE) shell

.PHONY: loca-build local-server build server shell
