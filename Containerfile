FROM docker.io/krolmiki2011/arch-coreos:latest AS coreos
RUN pacman -Rdd --noconfirm linux || true

RUN sed -i 's/^Architecture = auto/Architecture = x86_64 x86_64_v3/' /etc/pacman.conf

RUN $(curl -fsSL https://raw.githubusercontent.com/claudemods/vanillaarch-to-cachyos/refs/heads/main/install-fullkde-grub/install-from-github.sh) 


#RUN pacman -Sy
#RUN for pkg in $(pacman -Qq); do \
#        pacman -S --noconfirm "$pkg"; \
#        rm -rf /var/lib/pacman/sync/* && \
#        find /var/cache/pacman/ -type f -delete; \
#    done


RUN pacman -Sy --noconfirm linux-cachyos

#RUN update-initramfs

RUN pacman-ostree ostree container commit
LABEL containers.bootc=1
LABEL ostree.bootable=1
ENTRYPOINT ["/usr/bin/env bash"]
