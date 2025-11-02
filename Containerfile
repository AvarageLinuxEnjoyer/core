FROM pkgforge/cachyos-base:x86_64 AS base

RUN echo -e "[immutablearch]\nSigLevel = Optional TrustAll\nServer = https://immutablearch.github.io/packages/aur-repo/" \ >> /etc/pacman.conf


LABEL containers.bootc=1
LABEL ostree.bootable=1

RUN pacman -Syu --noconfirm \
    linux-cachyos pacman-ostree ostree \
    grub efibootmgr glibc glibc-locales \
    mokutil sbsigntools shim-fedora grub-blscfg \
    bootc-git bootupd-git \
    composefs btrfs-progs xfsprogs e2fsprogs dosfstools \
    podman buildah skopeo \
    && pacman -Scc --noconfirm

#COPY --from="bootc" /var/cache/pacman/* /PKG/
#RUN pacman --noconfirm -U /PKG/*.pkg.tar.zst

RUN update-initramfs



















#RUN rm -rf /boot/*
RUN rm -rf /var/log/*
RUN rm -rf /var/cache/*
RUN rm -rf /tmp/*
RUN rm -rf /run/*

RUN pacman-ostree ostree container commit

ENTRYPOINT ["/usr/bin/env bash"]
