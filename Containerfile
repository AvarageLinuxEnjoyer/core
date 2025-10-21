FROM ghcr.io/vanilla-os/core:latest AS vib

FROM ghcr.io/pkgforge/devscripts/cachyos-base:latest AS cachyos

RUN mkdir /vos
COPY --from=vib / /vos/

RUN ln -s /usr/bin/abroot /usr/bin/

RUN pacman --noconfirm -Syu
RUN pacman --noconfirm -Sy paru
RUN paru --noconfirm -Sy linux linux-headers linux-firmware podman distrobox 
