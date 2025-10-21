FROM cachyos/cachyos-v3:latest AS base

RUN echo -e "[immutablearch]\nSigLevel = Optional TrustAll\nServer = https://immutablearch.github.io/packages/aur-repo/" \ >> /etc/pacman.conf

RUN pacman -Syu --noconfirm

RUN pacman -Sy --noconfirm ostree grub-efi bootc-git bootupd-git shim-fedora pacman-ostree

RUN rm -rf /var/lib/pacman/sync/* && \
    find /var/cache/pacman/ -type f -delete

#FROM scratch
#COPY --from=base / /

LABEL containers.bootc 1
LABEL ostree.bootable 1
RUN pacman-ostree ostree container commit
