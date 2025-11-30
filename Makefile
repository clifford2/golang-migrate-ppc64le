# SPDX-FileCopyrightText: © 2025 Clifford Weinmann <https://www.cliffordweinmann.com/>
# SPDX-License-Identifier: MIT-0

# Use podman or docker?
ifeq ($(shell command -v podman 2> /dev/null),)
	CONTAINER_ENGINE := docker
else
	CONTAINER_ENGINE := podman
endif

# Command to install qemu-ppc64le
ifeq ($(CONTAINER_ENGINE),podman)
	BINFMT_INSTALL_CMD := sudo podman run --privileged --rm docker.io/tonistiigi/binfmt --install ppc64le
else
	BINFMT_INSTALL_CMD := docker run --privileged --rm docker.io/tonistiigi/binfmt --install ppc64le
endif

# Command to verify that qemu-ppc64le is working
BINFMT_TEST_CMD := $(CONTAINER_ENGINE) run --platform linux/ppc64le docker.io/ppc64le/debian:trixie-20250811 uname -a

# Build the image
.PHONY: build-image
build-image: check-depends
	bash ./check-version.sh
	test -s .version && ($(BINFMT_INSTALL_CMD) && bash ./build-image.sh) || echo 'No build required'
	@rm .version

# Verify that we have all required dependencies installed
# Written for Ubuntu 24.04 (used by GitHub action workflow)
.PHONY: check-depends
check-depends:
	@test -f /usr/bin/env || (apt-get update && apt-get install -y coreutils)
	@command -v git || (apt-get update && apt-get install -y git)
	@command -v bash || (apt-get update && apt-get install -y bash)
	@command -v podman || (apt-get update && apt-get install -y podman)
	@command -v curl || (apt-get update && apt-get install -y curl)
	@command -v jq || (apt-get update && apt-get install -y jq)
	@command -v docker
