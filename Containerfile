FROM cachyos/cachyos-v3:latest AS cachyos

RUN pacman -Sy --noconfirm lightdm
RUN systemctl enable lightdm

RUN bootc container lint
