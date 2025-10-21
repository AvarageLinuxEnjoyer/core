FROM ghcr.io/vanilla-os/core:latest AS vib

FROM ghcr.io/pkgforge/devscripts/cachyos-base:latest AS cachyos

COPY --from=vib /usr /usr
COPY --from=vib /var/lib /var/lib

RUN pacman --noconfirm -Syu
RUN pacman --noconfirm -Sy paru
RUN paru --noconfirm -Sy linux linux-headers linux-firmware podman distrobox 
