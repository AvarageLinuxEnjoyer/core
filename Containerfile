FROM cachyos/cachyos-v3:latest AS arch
ARG VMLINUZ=$( find /lib/modules/ -name "vmlinuz*" )
ARG INITRAMFS=$( find /lib/modules -name initramfs*.img | head -n 1 )


RUN mkdir -p /tmp/kernel
RUN cp -r /boot/vmlinuz-* /tmp/kernel/
RUN cp -r /lib/modules/* /tmp/kernel/modules/
RUN cp /boot/config-$(uname -r) /tmp/kernel/config

FROM ghcr.io/ublue-os/bazzite:latest
ARG VMLINUZ=$( find /lib/modules/ -name "vmlinuz*" )
ARG INITRAMFS=$( find /lib/modules -name initramfs*.img | head -n 1 )


RUN rm -rf /boot/vmlinuz-$(uname -r) /lib/modules/$(uname -r)

COPY --from=arch $VMLINUZ $VMLINUZ
COPY --from=arch $INITRAMFS $INITRAMFS

RUN bootc container lint
