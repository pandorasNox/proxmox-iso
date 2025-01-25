# # github.com/qemus/qemu-docker
# FROM ghcr.io/qemus/qemu-docker:6.13 AS kvm-runner

# ## os check
# RUN cat /etc/os-release | grep "bookworm"

# # COPY ./build.sh /build.sh

# # RUN set -Eeuo pipefail; \
# #     /build.sh;

# ================================================================================

# FROM docker.io/debian:bookworm-20250113-slim AS builder-base

# ARG DEBCONF_NOWARNINGS="yes"
# ARG DEBIAN_FRONTEND noninteractive

# RUN apt-get update && apt-get -y upgrade && \
#     apt-get --no-install-recommends -y install \
#         bash \
#         ca-certificates \
#         wget \
#         7zip \
#         procps \
#         qemu-utils \
#         qemu-system-x86 \
#         xz-utils \
#     && apt-get clean \
#     && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
#     ;

# ENV CPU_CORES="1"
# ENV RAM_SIZE="1G"
# ENV DISK_SIZE="16G"

# # ================================================================================

# FROM builder-base AS builder

# ## os check
# RUN cat /etc/os-release | grep "bookworm"

# SHELL ["/bin/bash", "-c"]
# COPY ./build.sh /build.sh

# RUN set -Eeuo pipefail; \
#     /build.sh;

# ================================================================================
# docker build --progress=plain -f Dockerfile .
FROM docker.io/ubuntu:24.04 AS kvm-proxmox-vm-img-builder

ENV DEBCONF_NOWARNINGS="yes"
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get -y upgrade && \
    apt-get --no-install-recommends -y install \
        7zip \
        bash \
        ca-certificates \
        curl \
        procps \
        qemu-utils \
        qemu-system-x86 \
        qemu-user-static \
        tree \
        wget \
        xz-utils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    ;

RUN <<EOF
echo "run architecture: $(uname -a)"

wget https://enterprise.proxmox.com/debian/proxmox-release-bookworm.gpg \
    -O /etc/apt/trusted.gpg.d/proxmox-release-bookworm.gpg \
;

printf '%s' \
    "7da6fe34168adc6e479327ba517796d4702fa2f8b4f0a9833f5ea6e6b48f6507a6da403a274fe201595edc86a84463d50383d07f64bdde2e3658108db7d6dc87 /etc/apt/trusted.gpg.d/proxmox-release-bookworm.gpg" \
    > proxmox-gpg.checksumfile.sha512 \
;

sha512sum -c proxmox-gpg.checksumfile.sha512;

apt-get update -q -y;

apt-get install -q -y software-properties-common;
command -v add-apt-repository;
add-apt-repository \
  "deb [arch=amd64] http://download.proxmox.com/debian/pve bookworm pve-no-subscription";

apt-get install -q -y binfmt-support;

EOF

RUN <<EOF
set -e;

echo "debug: apt-get install proxmox-auto-install-assistant";
    # echo \
    #   "deb [arch=amd64] [URL]http://download.proxmox.com/debian/pve[/URL] bookworm pve-no-subscription" \
    #   > /etc/apt/sources.list.d/pve-install-repo.list \
    # ;
echo \
  "deb [arch=amd64] http://download.proxmox.com/debian/pve bookworm pve-no-subscription" \
  > /etc/apt/sources.list.d/pve-install-repo.list \
;

apt update && apt install -y proxmox-auto-install-assistant;
proxmox-auto-install-assistant --version;
EOF

# RUN set -e; apt-get install -q -y pveversion; \
#   pveversion; apt update && apt policy proxmox-auto-install-assistant;
# RUN apt-get install -q -y \
#     proxmox-auto-install-assistant \
#   ;

ENV CPU_CORES="1"
ENV RAM_SIZE="1G"
ENV DISK_SIZE="16G"
