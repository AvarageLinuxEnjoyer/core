FROM krolmiki2011/arch-coreos:latest AS arch
RUN pacman --noconfirm -Rdd linux || true

RUN mkdir -p /PKG
RUN pacman --noconfirm -Sy
RUN pacman --noconfirm -Sw --cachedir /PKG \
    bootc-git \
    bootupd-git \
    pacman-ostree \
    && \
    echo "...done"


FROM pkgforge/cachyos-base:x86_64 AS cachyos
RUN pacman --noconfirm -Rdd linux || true 

# install
RUN pacman --noconfirm -Sy sddm base-devel dracut ostree composefs btrfs-progs e2fsprogs xfsprogs udev cpio zstd binutils dosfstools intel-ucode conmon crun netavark dbus dbus-glib glib2 skopeo shadow fastfetch micro grub grub-btrfs wayland linux-cachyos linux-cachyos-headers
RUN pacman --noconfirm -Sy mesa lib32-mesa vulkan-icd-loader lib32-vulkan-icd-loader nvidia nvidia-utils lib32-nvidia-utils

RUN mkdir -p /PKG
COPY --from='arch' /PKG /PKG
RUN pacman --noconfirm -U /PKG/*.pkg.tar.zst
RUN rm -rf /PKG

# services
RUN systemctl enable sddm

LABEL containers.bootc="1"
LABEL ostree.bootable="1"
