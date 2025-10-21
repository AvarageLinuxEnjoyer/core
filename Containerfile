FROM ghcr.io/vanilla-os/core:latest AS vib
FROM ghcr.io/pkgforge/devscripts/cachyos-base:latest AS builder

COPY --from="vib" /bin/abroot /bin/
