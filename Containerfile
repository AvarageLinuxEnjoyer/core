FROM docker.io/krolmiki2011/arch-coreos:latest AS core

FROM ghcr.io/pkgforge/devscripts/cachyos-base:latest AS base

COPY --from=core /var/cache/pacman/pkg/ /var/cache/pacman/pkg/

pacman --noconfirm -U /var/cache/pacman/pkg/*

RUN pacman -Syu --noconfirm
RUN pacman -Sy --noconfirm plasma



RUN rm -rf /var/lib/pacman/sync/* && \
    find /var/cache/pacman/ -type f -delete

RUN pacman-ostree ostree container commit
