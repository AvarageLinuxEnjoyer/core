FROM docker.io/krolmiki2011/arch-coreos:latest AS coreos

RUN pacman -Rdd --noconfirm linux || true

LABEL containers.bootc=1
LABEL ostree.bootable=1




RUN sed -i 's@#en_US.UTF-8@en_US.UTF-8@g' /etc/locale.gen
RUN echo "root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN yes | pacman-key --recv-keys F3B607488DB35A47 --keyserver keyserver.ubuntu.com
RUN yes | pacman-key --lsign-key F3B607488DB35A47

RUN echo "" >> /etc/pacman.conf
RUN echo "[cachyos]" >> /etc/pacman.conf
RUN echo "Include = /etc/pacman.d/cachyos-mirrorlist" >> /etc/pacman.conf
RUN curl https://raw.githubusercontent.com/CachyOS/CachyOS-PKGBUILDS/master/cachyos-mirrorlist/cachyos-mirrorlist -o /etc/pacman.d/cachyos-mirrorlist

pacman -Sy && \
	 pacman -S --needed --noconfirm cachyos-keyring cachyos-mirrorlist cachyos-v3-mirrorlist cachyos-v4-mirrorlist cachyos-hooks && \
	 pacman -Syu --noconfirm && \
     rm -rf /var/lib/pacman/sync/* && \
     find /var/cache/pacman/ -type f -delete





RUN update-initramfs

RUN pacman-ostree ostree container commit

ENTRYPOINT ["/usr/bin/env bash"]
