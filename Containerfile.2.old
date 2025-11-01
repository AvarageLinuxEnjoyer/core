#ARG BASE_PKGS=" ostree grub-efi bootc-git bootupd-git shim-fedora pacman-ostree "

FROM pkgforge/cachyos-base:x86_64 AS cachyos
#RUN echo -e "[immutablearch]\nSigLevel = Optional TrustAll\nServer = https://immutablearch.github.io/packages/aur-repo/" \ >> /etc/pacman.conf
RUN pacman --noconfirm -Sy linux-cachyos
#RUN pacman --noconfirm -Sy $BASE_PKGS

#FROM quay.io/centos-bootc/bootc-image-builder:latest AS fedora

#FROM quay.io/fedora/fedora-coreos:rawhide AS base

FROM quay.io/fedora/fedora-coreos:rawhide AS base

RUN mkdir -p /cachyos

COPY --from='cachyos' / /cachyos
#COPY --from='fedora' rootfs/ /
#COPY --from='fedora' / /

#RUN mkdir -p /boot/ostree/test
#RUN ln -s /cachyos/boot/* /boot/ostree/test/

LABEL containers.bootc="1"
LABEL ostree.bootable="1"
#LABEL org.osbuild.bootc.osname="archlinux"
#CMD ["/sbin/init"]
