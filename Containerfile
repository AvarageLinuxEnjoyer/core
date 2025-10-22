FROM cachyos/cachyos-v3:latest AS base

ARG BASE_PKGS=" ostree grub-efi bootc-git bootupd-git shim-fedora pacman-ostree "
ARG AUR=""

RUN echo -e "[immutablearch]\nSigLevel = Optional TrustAll\nServer = https://immutablearch.github.io/packages/aur-repo/" \ >> /etc/pacman.conf
#RUN echo -e "[immutablearch]\nSigLevel = Optional TrustAll\nServer = https://immutablearch.github.io/packages/aur-repo/" \ >> /etc/pacman.conf

RUN pacman -Syu --noconfirm


RUN pacman -Sy --noconfirm rustup && \
    export PATH="$HOME/.cargo/bin:$PATH" && \
    RUSTUP_NO_SELF_UPDATE=1 RUSTUP_IO_THREADS=4 rustup default stable && \
    rustup update stable



RUN pacman -S --noconfirm $BASE_PKGS

#RUN useradd -m -s /bin/bash aur && \
#    echo "aur ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/aur && \
#    mkdir -p /tmp_aur_build && chown -R aur /tmp_aur_build && \
#    install-packages-build git base-devel; \
#    runuser -u aur -- env -C /tmp_aur_build git clone 'https://aur.archlinux.org/paru-bin.git' && \
#    runuser -u aur -- env -C /tmp_aur_build/paru-bin makepkg -si --noconfirm && \
#    rm -rf /tmp_aur_build && \
#    runuser -u aur -- paru -S --needed --noconfirm $AUR; \
#    userdel -rf aur; rm -rf /home/aur /etc/sudoers.d/aur

#RUN rm -rf /var/lib/pacman/sync/* && \
#    find /var/cache/pacman/ -type f -delete

#FROM scratch
#COPY --from=base / /

LABEL containers.bootc="1"
LABEL ostree.bootable="1"

# RUN pacman-ostree ostree container commit
