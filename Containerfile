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



RUN pacman -S --noconfirm $BASE_PKGS linux-cachyos

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

#LABEL org.osbuild.bootc.version="1"
#LABEL org.osbuild.bootc.arch="x86_64"
#LABEL org.osbuild.bootc.variant="minimal"

#LABEL containers.bootc="1"
#LABEL ostree.bootable="1"
#LABEL org.osbuild.bootc.osname="archlinux"

# RUN pacman-ostree ostree container commit

#CMD ["/sbin/init"]
#RUN bootc container lint

FROM scratch

LABEL containers.bootc="1"
LABEL ostree.bootable="1"
LABEL org.osbuild.bootc.osname="archlinux"

# Optional metadata
LABEL org.osbuild.bootc.version="1"
LABEL org.osbuild.bootc.arch="x86_64"
LABEL org.osbuild.bootc.variant="minimal"

# Copy in the full root filesystem
COPY --from='base' / /
FROM scratch

# Validate and fix /etc/os-release
RUN mkdir -p /etc && \
    (test -f /etc/os-release || echo -e 'ID=arch\nNAME="Arch Linux"' > /etc/os-release) && \
    grep -q '^ID=arch' /etc/os-release

# Ensure /sbin/init exists and is executable
RUN mkdir -p /sbin && \
    (test -f /sbin/init || ln -sf /usr/lib/systemd/systemd /sbin/init) && \
    test -x /sbin/init

# Ensure real kernel and initramfs exist
RUN test -f /boot/vmlinuz-linux && \
    test -f /boot/initramfs-linux.img && \
    grep -q 'Linux' /boot/vmlinuz-linux

# Ensure kernel modules match kernel version
RUN test -d /lib/modules && \
    KVER=$(basename /boot/vmlinuz-linux | sed 's/vmlinuz-//') && \
    test -d /lib/modules/$KVER

CMD ["/sbin/init"]
