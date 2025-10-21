FROM docker.io/krolmiki2011/arch-coreos:latest AS core

FROM ghcr.io/pkgforge/devscripts/cachyos-base:latest AS base

COPY --from=core /etc /etc
COPY --from=core /bin /bin
COPY --from=core /sbin /sbin
COPY --from=core /usr /usr
COPY --from=core /lib /lib
COPY --from=core /lib64 /lib64

RUN pacman -Syu --noconfirm
RUN pacman -Sy --noconfirm plasma



rm -rf /var/lib/pacman/sync/* && \
     find /var/cache/pacman/ -type f -delete
RUN pacman-ostree ostree container commit
