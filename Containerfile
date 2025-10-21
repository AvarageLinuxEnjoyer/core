FROM docker.io/krolmiki2011/arch-coreos:latest AS base

# Set locale
RUN sed -i 's@#en_US.UTF-8@en_US.UTF-8@g' /etc/locale.gen
RUN echo "root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN pacman -Syu --noconfirm && \
     pacman -S --needed --noconfirm pacman-contrib git openssh sudo curl wget
RUN curl https://raw.githubusercontent.com/CachyOS/docker/master/pacman.conf -o /etc/pacman.conf
RUN curl https://raw.githubusercontent.com/CachyOS/CachyOS-PKGBUILDS/master/cachyos-mirrorlist/cachyos-mirrorlist -o /etc/pacman.d/cachyos-mirrorlist


## include to pacman own keyring to install signed packages
RUN  pacman-key --init && \
     pacman-key --recv-keys F3B607488DB35A47 --keyserver keyserver.ubuntu.com && \
     pacman-key --lsign-key F3B607488DB35A47 && \
     pacman -Sy && \
	 pacman -S --needed --noconfirm cachyos-keyring cachyos-mirrorlist cachyos-v3-mirrorlist cachyos-v4-mirrorlist cachyos-hooks && \
	 pacman -Syu --noconfirm && \
     rm -rf /var/lib/pacman/sync/* && \
     find /var/cache/pacman/ -type f -delete

RUN curl https://raw.githubusercontent.com/CachyOS/docker/master/pacman-v3.conf -o /etc/pacman.conf
RUN pacman -Syu --noconfirm && \
    rm -rf /var/lib/pacman/sync/* && \
    find /var/cache/pacman/ -type f -delete



#RUN useradd -m -s /bin/bash aur && \
#    echo "aur ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/aur && \
#    mkdir -p /tmp_aur_build && chown -R aur /tmp_aur_build && \
#    install-packages-build git base-devel; \
#    runuser -u aur -- env -C /tmp_aur_build git clone 'https://aur.archlinux.org/paru-bin.git' && \
#    runuser -u aur -- env -C /tmp_aur_build/paru-bin makepkg -si --noconfirm && \
#    rm -rf /tmp_aur_build && \
#    runuser -u aur -- paru -S --noconfirm grub-efi bootc-git bootupd-git shim-fedora pacman-ostree ; \
#    userdel -rf aur; rm -rf /home/aur /etc/sudoers.d/aur


RUN pacman -Syu --noconfirm
RUN pacman -Sy --noconfirm fastfetch linux linux-headers linux-firmware # plasma



RUN rm -rf /var/lib/pacman/sync/* && \
    find /var/cache/pacman/ -type f -delete

RUN pacman-ostree ostree container commit
