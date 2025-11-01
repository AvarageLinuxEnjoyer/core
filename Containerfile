FROM pkgforge/cachyos-base:x86_64 AS cachyos
RUN pacman --noconfirm -Rdd linux || true

RUN mkdir -p /cachyos
RUN pacman --noconfirm -Sy
RUN pacman --noconfirm -Sw --cachedir /cachyos (pacman -Qqe)

FROM krolmiki2011/arch-coreos:latest AS arch
RUN pacman --noconfirm -Rdd linux || true 

RUN mkdir -p /cachyos
COPY --from='cachyos' /cachyos /cachyos
RUN pacman --noconfirm -U /cachyos/*.pkg.tar.zst


# install
RUN pacman --noconfirm -Sy base-devel intel-ucore fastfetch sddm micro grub wayland linux-cachyos linux-cachyos-headers
RUN pacman --noconfirm -Sy mesa lib32-mesa vulkan-icd-loader lib32-vulkan-icd-loader nvidia nvidia-utils lib32-nvidia-utils

# services
RUN systemctl enable sddm

LABEL containers.bootc="1"
LABEL ostree.bootable="1"
