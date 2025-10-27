FROM cachyos/cachyos-v3:latest AS cachyos
RUN pacman --noconfirm -Sy linux-cachyos

#FROM quay.io/centos-bootc/bootc-image-builder:latest AS fedora

FROM quay.io/fedora/fedora-coreos:rawhide AS base

COPY --from='cachyos' / /cachyos
#COPY --from='fedora' rootfs/ /
#COPY --from='fedora' / /

LABEL containers.bootc="1"
LABEL ostree.bootable="1"
CMD ["/sbin/init"]
