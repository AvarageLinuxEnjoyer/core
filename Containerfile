#FROM pkgforge/cachyos-base:x86_64 AS cachyos
#RUN pacman --noconfirm -Rdd linux || true

# install
#RUN pacman --noconfirm -Sy sddm base-devel dracut ostree composefs btrfs-progs e2fsprogs xfsprogs udev cpio zstd binutils dosfstools intel-ucode conmon crun netavark dbus dbus-glib glib2 skopeo shadow fastfetch micro grub grub-btrfs wayland linux-cachyos linux-cachyos-headers
#RUN pacman --noconfirm -Sy mesa lib32-mesa vulkan-icd-loader lib32-vulkan-icd-loader nvidia nvidia-utils lib32-nvidia-utils

#RUN mkdir -p /PKG
#COPY --from='arch' /PKG /PKG
#RUN pacman --noconfirm -U /PKG/*.pkg.tar.zst
#RUN rm -rf /PKG

#RUN mv /etc/pacman.d/gnupg /etc/pacman.d/gnupg.old
#RUN mv /etc/pacman.conf /etc/pacman.conf.old
#RUN mv /etc/pacman.d /etc/pacman.d.old

#COPY --from='cachyos' /etc/pacman.conf /etc/pacman.conf
#COPY --from='cachyos' /etc/pacman.d /etc/pacman.d
#COPY --from='cachyos' /etc/pacman.d/gnupg /etc/pacman.d/gnupg


FROM krolmiki2011/arch-coreos:latest AS arch
RUN pacman --noconfirm -Rdd linux || true





# Set locale
RUN sed -i 's@#en_US.UTF-8@en_US.UTF-8@g' /etc/locale.gen
RUN echo "root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN pacman -Syu --noconfirm && \
    pacman -S --needed --noconfirm pacman-contrib git openssh sudo curl wget
RUN curl https://raw.githubusercontent.com/CachyOS/docker/master/pacman.conf -o /etc/pacman.conf
RUN curl https://raw.githubusercontent.com/CachyOS/CachyOS-PKGBUILDS/master/cachyos-mirrorlist/cachyos-mirrorlist -o /etc/pacman.d/cachyos-mirrorlist


## include to pacman own keyring to install signed packages
RUN pacman-key --init && \
    pacman-key --recv-keys F3B607488DB35A47 --keyserver keyserver.ubuntu.com && \
    pacman-key --lsign-key F3B607488DB35A47 && \
    pacman -Sy && \
    pacman -S --needed --noconfirm cachyos-keyring cachyos-mirrorlist cachyos-v3-mirrorlist cachyos-v4-mirrorlist cachyos-hooks pacman && \
    pacman -Syu --noconfirm && \
    rm -rf /var/lib/pacman/sync/* && \
    find /var/cache/pacman/ -type f -delete

RUN curl https://raw.githubusercontent.com/CachyOS/docker/master/pacman-v3.conf -o /etc/pacman.conf
RUN pacman -Syu --noconfirm && \
    rm -rf /var/lib/pacman/sync/* && \
    find /var/cache/pacman/ -type f -delete

RUN pacman -Syu --noconfirm


RUN pacman --noconfirm -Sy fastfetch micro linux-cachyos


LABEL containers.bootc="1"
LABEL ostree.bootable="1"

