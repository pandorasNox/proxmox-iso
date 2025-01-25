# github.com/qemus/qemu-docker
FROM ghcr.io/qemus/qemu-docker:6.13 AS kvm-runner

COPY ./build.sh /build.sh

RUN set -Eeuo pipefail; \
    /build.sh;


