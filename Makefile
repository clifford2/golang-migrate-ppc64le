# SPDX-FileCopyrightText: © 2025 Clifford Weinmann <https://www.cliffordweinmann.com/>
# SPDX-License-Identifier: MIT-0

# Use podman or docker?
ifeq ($(shell command -v podman 2> /dev/null),)
	CONTAINER_ENGINE := docker
else
	CONTAINER_ENGINE := podman
endif

# Build the image
.PHONY: build-image
build-image: check-depends
	bash ./check-version.sh
	test -s .version && (docker run --privileged --rm tonistiigi/binfmt --install ppc64le && $(CONTAINER_ENGINE) login ghcr.io/clifford2 && bash ./build-image.sh) || echo 'No build required'
	@rm .version

# Verify that we have all required dependencies installed
# Written for Ubuntu 24.04
.PHONY: check-depends
check-depends:
	@command -v git || (apt-get update && apt-get install -y git)
	@command -v bash || (apt-get update && apt-get install -y bash)
	@command -v podman || (apt-get update && apt-get install -y podman)
	@command -v curl || (apt-get update && apt-get install -y curl)
	@command -v jq || (apt-get update && apt-get install -y jq)
	@command -v docker
