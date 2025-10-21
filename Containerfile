FROM cachyos/cachyos-v3:latest AS base

ARG AUR=" ostree grub-efi bootc-git bootupd-git shim-fedora pacman-ostree "

#RUN echo -e "[immutablearch]\nSigLevel = Optional TrustAll\nServer = https://immutablearch.github.io/packages/aur-repo/" \ >> /etc/pacman.conf

RUN pacman -Syu --noconfirm

RUN pacman -Rns --noconfirm rustup || true
RUN pacman -Rns --noconfirm rust || true
RUN pacman -S --noconfirm base-devel
RUN pacman -S --noconfirm rustup cargo

ENV PATH="/root/.cargo/bin:${PATH}"

RUN rustup default stable

RUN useradd -m -s /bin/bash aur && \
    echo "aur ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/aur && \
    mkdir -p /tmp_aur_build && chown -R aur /tmp_aur_build && \
    install-packages-build git base-devel; \
    runuser -u aur -- env -C /tmp_aur_build git clone 'https://aur.archlinux.org/paru-bin.git' && \
    runuser -u aur -- env -C /tmp_aur_build/paru-bin makepkg -si --noconfirm && \
    rm -rf /tmp_aur_build && \
    runuser -u aur -- paru -S --noconfirm --needed $AUR; \
    userdel -rf aur; rm -rf /home/aur /etc/sudoers.d/aur

#RUN rm -rf /var/lib/pacman/sync/* && \
#    find /var/cache/pacman/ -type f -delete

#FROM scratch
#COPY --from=base / /

LABEL containers.bootc="1"
LABEL ostree.bootable="1"

RUN pacman-ostree ostree container commit
