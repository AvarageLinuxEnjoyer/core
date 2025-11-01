FROM pkgforge/cachyos-base:x86_64 AS cachyos
RUN pacman --noconfirm -Rdd linux || true

RUN mkdir -p /cachyos
RUN pacman --noconfirm -Sy
RUN pacman --noconfirm -Sw --cachedir /cachyos \
    bootc-git \
    bootupd-git \
    && \
    echo "...done"



FROM krolmiki2011/arch-coreos:latest AS arch
RUN pacman --noconfirm -Rdd linux || true 


# install
RUN pacman --noconfirm -Sy sddm base-devel dracut ostree composefs btrfs-progs e2fsprogs xfsprogs udev cpio zstd binutils dosfstools intel-ucore conmon crun netavark dbus dbus-glib glib2 skopeo shadow fastfetch micro grub grub-btrfs wayland linux-cachyos linux-cachyos-headers
RUN pacman --noconfirm -Sy mesa lib32-mesa vulkan-icd-loader lib32-vulkan-icd-loader nvidia nvidia-utils lib32-nvidia-utils

RUN mkdir -p /cachyos
COPY --from='cachyos' /cachyos /cachyos
RUN pacman --noconfirm -U /cachyos/*.pkg.tar.zst

# services
RUN systemctl enable sddm

LABEL containers.bootc="1"
LABEL ostree.bootable="1"
