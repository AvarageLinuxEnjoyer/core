FROM pkgforge/cachyos-base:x86_64 AS cachyos
#RUN pacman --noconfirm -Rdd linux || true

# install
#RUN pacman --noconfirm -Sy sddm base-devel dracut ostree composefs btrfs-progs e2fsprogs xfsprogs udev cpio zstd binutils dosfstools intel-ucode conmon crun netavark dbus dbus-glib glib2 skopeo shadow fastfetch micro grub grub-btrfs wayland linux-cachyos linux-cachyos-headers
#RUN pacman --noconfirm -Sy mesa lib32-mesa vulkan-icd-loader lib32-vulkan-icd-loader nvidia nvidia-utils lib32-nvidia-utils

#RUN mkdir -p /PKG
#COPY --from='arch' /PKG /PKG
#RUN pacman --noconfirm -U /PKG/*.pkg.tar.zst
#RUN rm -rf /PKG


FROM krolmiki2011/arch-coreos:latest AS arch
RUN pacman --noconfirm -Rdd linux || true

RUN mv /etc/pacman.d/gnupg /etc/pacman.d/gnupg.old
RUN mv /etc/pacman.conf /etc/pacman.conf.old
RUN mv /etc/pacman.d /etc/pacman.d.old

COPY --from='cachyos' /etc/pacman.conf /etc/pacman.conf
COPY --from='cachyos' /etc/pacman.d /etc/pacman.d
COPY --from='cachyos' /etc/pacman.d/gnupg /etc/pacman.d/gnupg

RUN pacman --noconfirm -Sy fastfetch micro linux-cachyos


LABEL containers.bootc="1"
LABEL ostree.bootable="1"
