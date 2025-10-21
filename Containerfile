FROM ghcr.io/pkgforge/devscripts/cachyos-base:latest AS cachyos

FROM ghcr.io/vanilla-os/core:latest AS vib

COPY --from=cachyos / /

RUN pacman --noconfirm -Syu
RUN pacman --noconfirm -Sy paru
RUN paru --noconfirm -Sy linux linux-headers linux-firmware podman distrobox 
