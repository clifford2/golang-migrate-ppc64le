# golang-migrate for ppc64le

## About

This code builds a linux/**ppc64le** container image of the
[golang-migrate](https://github.com/golang-migrate/migrate) tool.

For linux/amd64 & linux/arm64 images, see
<https://hub.docker.com/r/migrate/migrate>.

## TODO

This build is triggered by a GitHub Action weekly scheduled run.
Scheduled workflows are disabled automatically after 60 days of repository
inactivity, so I need to find a smarter way to trigger this.

## Manual Build

The build essentially automates these manual steps:

```sh
git clone https://github.com/golang-migrate/migrate.git
cd migrate
ver=$(git describe --tags --abbrev=0)
git checkout "${ver}"
sed -i -e 's|FROM golang|FROM docker.io/ppc64le/golang|' -e 's|FROM alpine|FROM docker.io/ppc64le/alpine|' Dockerfile
podman build --platform linux/ppc64le -t ghcr.io/clifford2/migrate:${ver}-ppc64le
podman push ghcr.io/clifford2/migrate:${ver}-ppc64le
```
