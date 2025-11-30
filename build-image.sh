#!/usr/bin/env bash
# Build <https://github.com/golang-migrate/migrate> container image for ppc64le.
#
# SPDX-FileCopyrightText: © 2025 Clifford Weinmann <https://www.cliffordweinmann.com/>
# SPDX-License-Identifier: MIT-0

# Configure
arch='ppc64le'

# .version is updated by check-version.sh, with a new version number if
# a build is required, or an empty file if no build is required.
if [ -s .version ]
then
	ver=$(cat .version)
else
	# fallback in case check-version.sh was not run
	ver=$(curl -Ls https://api.github.com/repos/golang-migrate/migrate/releases/latest | jq -r '.name')
fi
if [ -z "${ver}" ]
then
	echo "No ${arch} build required"
	exit 0
fi
imgtag="${ver}-${arch}"

# Build
if [ "$arch" = 'amd64' -o "$arch" = 'arm64' ]
then
	imgname='docker.io/migrate/migrate'
else
	imgname='ghcr.io/clifford2/migrate'
fi

# Try and pull existing image
"${CONTAINER_ENGINE:-podman}" pull --platform linux/${arch} "${imgname}:${imgtag}"
rc=$?

# If no existing image found, build one
if [ $rc -ne 0 ]
then
	# Build new image
	builddir="/tmp/golang-migrate.$$"
	echo "Building ${imgname}:${imgtag} in $builddir"
	git clone https://github.com/golang-migrate/migrate.git $builddir || ( echo "Error cloning source" && exit 1 )
	cd "$builddir" || ( echo "Error changing directory to source ($builddir)" && exit 1 )
	git checkout "$ver" && sed -i -e "s|FROM golang|FROM docker.io/${arch}/golang|" -e "s|FROM alpine|FROM docker.io/${arch}/alpine|" Dockerfile && time ${CONTAINER_ENGINE:-podman} build --platform linux/${arch} --build-arg TARGETARCH=${arch} --build-arg VERSION="$(echo ${ver} | cut -c2-)" -t "${imgname}:${imgtag}" . && ${CONTAINER_ENGINE:-podman} push "${imgname}:${imgtag}"
	rc=$?
	cd /tmp && rm -rf "$builddir"
fi

if [ $rc -eq 0 ]
then
	echo "Done"
else
	echo "Something went wrong"
fi
exit $rc
