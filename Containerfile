FROM docker.io/krolmiki2011/arch-coreos:latest AS core

FROM ghcr.io/pkgforge/devscripts/cachyos-base:latest AS base

COPY --from=core /etc /etc
COPY --from=core /bin /bin
COPY --from=core /sbin /sbin
COPY --from=core /usr/bin /usr/bin
COPY --from=core /usr/lib /usr/lib
COPY --from=core /usr/libexec /usr/libexec
COPY --from=core /usr/sbin /usr/sbin
COPY --from=core /usr/share /usr/share
#COPY --from=core /usr/local /usr/local
COPY --from=core /usr/include /usr/include
COPY --from=core /usr/lib32 /usr/lib32
COPY --from=core /usr/src /usr/src
COPY --from=core /lib /lib
COPY --from=core /lib64 /lib64

RUN pacman -Syu --noconfirm
RUN pacman -Sy --noconfirm plasma



RUN rm -rf /var/lib/pacman/sync/* && \
    find /var/cache/pacman/ -type f -delete
RUN pacman-ostree ostree container commit
