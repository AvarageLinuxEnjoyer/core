FROM ghcr.io/xeniameraki/arch-bootc:latest

RUN pacman --noconfirm -Rdd $( pacman -Qqe )

RUN pacman --noconfirm -S linux-cachyos plasma fastfetch micro

RUN bootc container init
