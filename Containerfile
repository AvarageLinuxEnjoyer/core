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








# Move kernel, initramfs, and modules into /build/rootfs
RUN set -eux; \
    mkdir -p /build/rootfs/{boot,usr/lib/modules}; \
    \
    echo ">>> Copying any kernel images from /boot..."; \
    rsync -av /boot/vmlinuz* /build/rootfs/boot/ 2>/dev/null || echo "No vmlinuz files found"; \
    \
    echo ">>> Copying any initramfs images from /boot..."; \
    rsync -av /boot/initramfs*.img /build/rootfs/boot/ 2>/dev/null || echo "No initramfs files found"; \
    \
    echo ">>> Copying all kernel module directories..."; \
    rsync -av /usr/lib/modules/* /build/rootfs/usr/lib/modules/ 2>/dev/null || echo "No modules found"; \
    \
    echo ">>> Done. Kernel files are now in /build/rootfs"











#RUN rm -rf /boot/*
RUN rm -rf /var/log/*
RUN rm -rf /var/cache/*
RUN rm -rf /tmp/*
RUN rm -rf /run/*

ENTRYPOINT ["/usr/bin/bash"]
