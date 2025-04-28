:
# Build <https://github.com/golang-migrate/migrate> container image for ppc64le.
# Images for amd64 and arm64 are available at <https://hub.docker.com/r/migrate/migrate>.
#
# SPDX-FileCopyrightText: © 2025 Clifford Weinmann <https://www.cliffordweinmann.com/>
# SPDX-License-Identifier: MIT-0

# Configure
arch='ppc64le'
ver='v4.18.3'
tag="${ver}-${arch}"

# Build
if [ "$arch" = 'amd64' -o "$arch" = 'arm64' ]
then
	imgname='docker.io/migrate/migrate'
else
	imgname='ghcr.io/clifford2/migrate'
fi

# Try and pull existing image
"${CONTAINER_ENGINE:-podman}" pull --platform linux/${arch} "${imgname}:${tag}"
rc=$?

# If no existing image found, build one
if [ $rc -ne 0 ]
then
	# Build new image
	builddir="/tmp/golang-migrate.$$"
	echo "Building ${imgname}:${tag} in $builddir"
	git clone https://github.com/golang-migrate/migrate.git $builddir || ( echo "Error cloning source" && exit 1 )
	cd "$builddir" || ( echo "Error changing directory to source ($builddir)" && exit 1 )
	git checkout "$ver" && sed -i -e "s|FROM golang|FROM docker.io/${arch}/golang|" -e "s|FROM alpine|FROM docker.io/${arch}/alpine|" Dockerfile && time ${CONTAINER_ENGINE:-podman} build --platform linux/${arch} --build-arg TARGETARCH=${arch} -t "${imgname}:${tag}" . && ${CONTAINER_ENGINE:-podman} push "${imgname}:${tag}"
	rc=$?
	cd /tmp && rm -rf "$builddir"
fi

if [ $rc -eq 0 ]
then
	echo -e "\nDone"
else
	echo -e "\nSomething went wrong"
fi
exit $rc
