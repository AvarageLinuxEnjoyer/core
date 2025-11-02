FROM pkgforge/cachyos-base:x86_64 AS cachyos
RUN pacman -Rdd --noconfirm linux || true

RUN pacman --noconfirm -Sw

FROM krolmiki2011/arch-coreos:latest AS coreos
RUN pacman -Rdd --noconfirm linux || true

COPY --from=cachyos /usr /usr
COPY --from=cachyos /etc /etc

RUN pacman -Syyu --noconfirm \
    && pacman --noconfirm -U /var/cache/pacman/pkg/*.pkg.tar.zst \
    && rm -rf /var/cache/pacman/pkg/*

pacman --noconfirm -Sy linux-cachyos linux-cachyos-headers

LABEL containers.bootc="1"
LABEL ostree.bootable="1"

CMD ["/bin/bash"]
