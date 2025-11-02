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

RUN update-initramfs
RUN mv /usr/lib/modules/*-azure/vmlinuz* /usr/lib/modules/cachyos*/ && \
    mv /usr/lib/modules/*-azure/initramfs*.img /usr/lib/modules/cachyos*/ && \
    mv /usr/lib/modules/*-azure/vmlinuz* /boot/ && \
    mv /usr/lib/modules/*-azure/initramfs*.img /boot/ \


#RUN rm -rf /boot/*
RUN rm -rf /var/log/*
RUN rm -rf /var/cache/*
RUN rm -rf /tmp/*
RUN rm -rf /run/*

ENTRYPOINT ["/usr/bin/bash"]
