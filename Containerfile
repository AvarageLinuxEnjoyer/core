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
#RUN cd /usr/lib/modules/*-azure/ && mv ./vmlinuz* /usr/lib/modules/cachyos*/
#RUN cd /usr/lib/modules/*-azure/ && mv ./initramfs*.img /usr/lib/modules/cachyos*/
RUN cd /usr/lib/modules/*-azure/ && mv ./vmlinuz*  /boot/
RUN cd /usr/lib/modules/*-azure/ && mv ./initramfs*.img /boot/


#RUN rm -rf /boot/*
RUN rm -rf /var/log/*
RUN rm -rf /var/cache/*
RUN rm -rf /tmp/*
RUN rm -rf /run/*

ENTRYPOINT ["/usr/bin/bash"]
