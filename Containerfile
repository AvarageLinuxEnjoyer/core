FROM krolmiki2011/arch-coreos:latest AS bootc

RUN rm -rf /var/cache/pacman/*

RUN pacman --noconfirm -Sw bootc-git

FROM pkgforge/cachyos-base:x86_64 AS base

LABEL containers.bootc=1
LABEL ostree.bootable=1

RUN pacman -Syu --noconfirm \
    linux-cachyos nvidia nvidia-utils steam lutris ostree \
    grub efibootmgr \
    && pacman -Scc --noconfirm

COPY --from="bootc" /var/cache/pacman/* /PKG/
RUN pacman --noconfirm -U /PKG/*.pkg.tar.zst

RUN mkdir -p /usr/lib/modules/$(uname -r) && \
    mv /boot/vmlinuz-linux-cachyos /usr/lib/modules/$(uname -r)/vmlinuz && \
    mv /boot/initramfs-linux-cachyos.img /usr/lib/modules/$(uname -r)/initramfs.img

RUN rm -rf /boot/*
RUN rm -rf /var/log/*
RUN rm -rf /var/cache/*
RUN rm -rf /tmp/*
RUN rm -rf /run/*

ENTRYPOINT ["/usr/bin/bash"]
