FROM docker.io/krolmiki2011/arch-coreos:latest AS coreos
RUN pacman -Rdd --noconfirm linux || true

RUN sed -i 's/^Architecture = auto/Architecture = x86_64 x86_64_v3/' /etc/pacman.conf
RUN cp /etc/pacman.conf /etc/pacman.conf.old

RUN pacman-key --init && pacman-key --populate archlinux && pacman-key --recv-keys F3B607488DB35A47 --keyserver keyserver.ubuntu.com && yes | pacman-key --lsign-key F3B607488DB35A47

RUN rm -rf /var/lib/pacman/sync/* && \
    find /var/cache/pacman/ -type f -delete

RUN cat << 'EOF' >> /etc/pacman.conf
[cachyos]
Include = /etc/pacman.d/cachyos-mirrorlist
EOF
RUN curl https://raw.githubusercontent.com/CachyOS/CachyOS-PKGBUILDS/master/cachyos-mirrorlist/cachyos-mirrorlist -o /etc/pacman.d/cachyos-mirrorlist

RUN pacman -Sy
RUN pacman -S --needed --noconfirm cachyos-keyring cachyos-mirrorlist cachyos-v3-mirrorlist cachyos-v4-mirrorlist cachyos-hooks
RUN pacman -S --needed --noconfirm pacman

RUN rm -rf /var/lib/pacman/sync/* && \
    find /var/cache/pacman/ -type f -delete

RUN rm -rf /etc/pacman.conf && mv /etc/pacman.conf.old /etc/pacman.conf

RUN cat << 'EOF' >> /etc/pacman.conf
[cachyos-v3]
Include = /etc/pacman.d/cachyos-v3-mirrorlist
[cachyos-core-v3]
Include = /etc/pacman.d/cachyos-v3-mirrorlist
[cachyos-extra-v3]
Include = /etc/pacman.d/cachyos-v3-mirrorlist
[cachyos]
Include = /etc/pacman.d/cachyos-mirrorlist
EOF


RUN pacman -Sy
RUN for pkg in $(pacman -Qq); do \
        pacman -S --noconfirm "$pkg"; \
        rm -rf /var/lib/pacman/sync/* && \
        find /var/cache/pacman/ -type f -delete; \
    done


RUN pacman -Sy --noconfirm linux-cachyos

#RUN update-initramfs

RUN pacman-ostree ostree container commit
LABEL containers.bootc=1
LABEL ostree.bootable=1
ENTRYPOINT ["/usr/bin/env bash"]
