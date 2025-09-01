#!/usr/bin/env bash
# Check whether we have a ppc64le container image for the latest version of
# <https://github.com/golang-migrate/migrate>.
# This script writes the desired version to a .version file if a new build is
# required, or creates an empty .version file if no build is required.
#
# SPDX-FileCopyrightText: © 2025 Clifford Weinmann <https://www.cliffordweinmann.com/>
# SPDX-License-Identifier: MIT-0

# Configure
arch='ppc64le'
ver=$(curl -Ls https://api.github.com/repos/golang-migrate/migrate/releases/latest | jq -r '.name')
imgname='ghcr.io/clifford2/migrate'
imgtag="${ver}-${arch}"

# Try and pull existing image
"${CONTAINER_ENGINE:-podman}" pull --platform linux/${arch} "${imgname}:${imgtag}"
rc=$?

# If we need to build the image, write the version to a file
if [ $rc -eq 0 ]
then
	echo "We already have a version ${ver} image"
	> .version
else
	echo "Version ${ver} image needs to be built"
	echo "${ver}" > .version
fi
