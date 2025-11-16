FROM cachyos/cachyos-v3:latest AS cachyos

RUN pacman -Sy --noconfirm linux-cachyos

FROM quay.io/centos/centos:latest

RUN rm -rf /usr/lib/modules/*

COPY --from=cachyos /usr/lib/modules/* /usr/lib/modules/

RUN bootc container lint
