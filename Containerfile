FROM ghcr.io/pkgforge/devscripts/cachyos-base:latest AS base

RUN pacman --noconfirm -Sy paru

RUN paru --noconfirm -Sy \
bootc-git \
pacman-ostree \
bootupd-git \
grub-efi \
shim-fedora \
ostree



RUN pacman -Syu --noconfirm
RUN pacman -Sy --noconfirm fastfetch linux linux-headers linux-hardware # plasma



RUN rm -rf /var/lib/pacman/sync/* && \
    find /var/cache/pacman/ -type f -delete

RUN pacman-ostree ostree container commit
