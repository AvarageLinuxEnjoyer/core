FROM cachyos/cachyos-v3:latest AS cachyos

FROM ghcr.io/winblues/vauxite-minimal:latest

RUN rm -rf /lib/modules/*

COPY --from=cachyos /lib/modules/* /lib/modules/

RUN bootc container lint
