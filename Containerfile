FROM pkgforge/cachyos-base:x86_64 AS base

RUN echo -e "[immutablearch]\nSigLevel = Optional TrustAll\nServer = https://immutablearch.github.io/packages/aur-repo/" \ >> /etc/pacman.conf


LABEL containers.bootc=1
LABEL ostree.bootable=1

RUN pacman -Syu --noconfirm \
    bootc-git pacman-ostree grub-efi linux-cachyos ostree \
    grub efibootmgr glibc glibc-locales \
    mokutil sbsigntools shim-fedora grub-blscfg \
    bootupd-git composefs btrfs-progs xfsprogs \
    e2fsprogs dosfstools podman

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
