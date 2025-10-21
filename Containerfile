FROM ghcr.io/pkgforge/devscripts/cachyos-base:latest AS base




RUN useradd -m -s /bin/bash aur && \
    echo "aur ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/aur && \
    mkdir -p /tmp_aur_build && chown -R aur /tmp_aur_build && \
    install-packages-build git base-devel; \
    runuser -u aur -- env -C /tmp_aur_build git clone 'https://aur.archlinux.org/paru-bin.git' && \
    runuser -u aur -- env -C /tmp_aur_build/paru-bin makepkg -si --noconfirm && \
    rm -rf /tmp_aur_build && \
    runuser -u aur -- paru -S --noconfirm ostree grub-efi bootc-git bootupd-git shim-fedora pacman-ostree ; \
    userdel -rf aur; rm -rf /home/aur /etc/sudoers.d/aur


RUN pacman -Syu --noconfirm
RUN pacman -Sy --noconfirm fastfetch linux linux-headers linux-hardware # plasma



RUN rm -rf /var/lib/pacman/sync/* && \
    find /var/cache/pacman/ -type f -delete

RUN pacman-ostree ostree container commit
