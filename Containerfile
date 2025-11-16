FROM cachyos/cachyos-v3:latest AS cachyos

RUN pacman -Sy --noiconfirm linux-cachyos

FROM ghcr.io/winblues/vauxite-minimal:latest

RUN rm -rf /usr/lib/modules/*

COPY --from=cachyos /usr/lib/modules/* /usr/lib/modules/

RUN bootc container lint
