CONTAINER_IMAGE_TAG = 0.71.1
CONTAINER_IMAGE_NAME = klakegg/hugo
CONTAINER_IMAGE = $(CONTAINER_IMAGE_NAME):$(CONTAINER_IMAGE_TAG)

SERVER_PORT = 1313
HUGO_ENV = DEV	# or "production"

server:
	podman run --rm -it --volume $(PWD):/src --publish $(SERVER_PORT):1313 $(CONTAINER_IMAGE) server

build:
	podman run --rm -it --volume $(PWD):/src --env HUGO_ENV=$(HUGO_ENV) $(CONTAINER_IMAGE)

shell:
	podman run --rm -it --volume $(PWD):/src --entrypoint /bin/sh $(CONTAINER_IMAGE)

.PHONY: build server
