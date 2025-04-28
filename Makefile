


# Use podman or docker?
ifeq ($(shell command -v podman 2> /dev/null),)
	CONTAINER_ENGINE := docker
else
	CONTAINER_ENGINE := podman
endif

# Current version
MIGRATE_VERSION := v4.18.3

# Build the image
.PHONY: build-image
build-image:
	docker run --privileged --rm tonistiigi/binfmt --install ppc64le
	$(CONTAINER_ENGINE) login ghcr.io/clifford2
	bash ./build-image.sh
