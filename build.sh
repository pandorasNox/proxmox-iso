#!/usr/bin/env bash

set -Eeuo pipefail;
set -x;

echo "run architecture: $(uname -a)"

wget https://enterprise.proxmox.com/debian/proxmox-release-bookworm.gpg \
    -O /etc/apt/trusted.gpg.d/proxmox-release-bookworm.gpg \
;

printf '%s' \
    "7da6fe34168adc6e479327ba517796d4702fa2f8b4f0a9833f5ea6e6b48f6507a6da403a274fe201595edc86a84463d50383d07f64bdde2e3658108db7d6dc87 /etc/apt/trusted.gpg.d/proxmox-release-bookworm.gpg" \
    > proxmox-gpg.checksumfile.sha512 \
;

sha512sum -c proxmox-gpg.checksumfile.sha512;

echo "debug: apt-get update";
apt-get update -q -y;
apt install software-properties-common

# add proxmox package list repository
add-apt-repository "deb [arch=amd64] http://download.proxmox.com/debian/pve bookworm pve-no-subscription"

echo "debug: apt-get update";
apt-get update -q -y;

echo "debug: apt-get install binfmt-support";
apt-get install -q -y \
    binfmt-support \
;

echo "debug: apt-get install curl";
apt-get install -q -y \
    curl \
;

apt-cache search qemu;

echo "debug: apt-get install qemu-system-x86";
apt-get install -q -y \
    qemu-system-x86 \
;

echo "debug: apt-get install qemu-user-static";
apt-get install -q -y \
    qemu-user-static \
;

echo "debug: apt-get install tree";
apt-get install -q -y \
    tree \
;

apt-cache search proxmox;

echo "debug: apt-get install proxmox-auto-install-assistant";
apt-get install -q -y \
    proxmox-auto-install-assistant \
;
