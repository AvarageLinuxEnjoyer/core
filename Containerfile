FROM krolmiki2011/arch-coreos:latest AS arch
RUN pacman --noconfirm -Rdd linux || true

# 1) Expose build args for architecture
ARG TARGETARCH
ARG TARGETPLATFORM
ARG EXPECTED_ARCH

# 2) First stage: pull the base image (cachyos‐base) for whatever platform is requested,
#    but assume you expect x86_64 (amd64) originally
FROM --platform=${TARGETPLATFORM} pkgforge/cachyos-base:x86_64 AS base

# 3) Check that the actual architecture matches what you expect
RUN arch=$(uname -m) \
    && case "${TARGETARCH}" in \
         amd64) expected="x86_64" ;; \
         arm64) expected="aarch64" ;; \
         *) expected="${TARGETARCH}" ;; \
       esac \
    && if [ "$arch" != "$expected" ]; then \
         echo "ERROR: Base image architecture ($arch) does not match TARGETARCH=${TARGETARCH} (expected $expected)"; \
         exit 1; \
       fi

# 4) Pass the architecture via an ENV (or ARG) into the next stage
ENV BASE_ARCH=${TARGETARCH}

# 5) Second stage: pull the arch-coreos image for the same architecture
FROM --platform=linux/${BASE_ARCH} krolmiki2011/arch-coreos:latest AS final

# 6) Post‐pull sanity check
RUN arch2=$(uname -m) \
    && case "${BASE_ARCH}" in \
         amd64) expected2="x86_64" ;; \
         arm64) expected2="aarch64" ;; \
         *) expected2="${BASE_ARCH}" ;; \
       esac \
    && if [ "$arch2" != "$expected2" ]; then \
         echo "ERROR: Arch-coreos stage architecture ($arch2) does not match BASE_ARCH=${BASE_ARCH} (expected $expected2)"; \
         exit 1; \
       fi
















# Set locale
RUN sed -i 's@#en_US.UTF-8@en_US.UTF-8@g' /etc/locale.gen
RUN echo "root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN pacman -Syu --noconfirm && \
    pacman -S --needed --noconfirm pacman-contrib git openssh sudo curl wget
RUN curl https://raw.githubusercontent.com/CachyOS/docker/master/pacman.conf -o /etc/pacman.conf
RUN curl https://raw.githubusercontent.com/CachyOS/CachyOS-PKGBUILDS/master/cachyos-mirrorlist/cachyos-mirrorlist -o /etc/pacman.d/cachyos-mirrorlist


## include to pacman own keyring to install signed packages
RUN pacman-key --init && \
    pacman-key --recv-keys F3B607488DB35A47 --keyserver keyserver.ubuntu.com && \
    pacman-key --lsign-key F3B607488DB35A47 && \
    pacman -Sy && \
    pacman -S --needed --noconfirm cachyos-keyring cachyos-mirrorlist cachyos-v3-mirrorlist cachyos-v4-mirrorlist cachyos-hooks pacman && \
    pacman -Syu --noconfirm && \
    rm -rf /var/lib/pacman/sync/* && \
    find /var/cache/pacman/ -type f -delete

RUN curl https://raw.githubusercontent.com/CachyOS/docker/master/pacman-v3.conf -o /etc/pacman.conf
RUN pacman -Syu --noconfirm && \
    rm -rf /var/lib/pacman/sync/* && \
    find /var/cache/pacman/ -type f -delete

RUN pacman -Syu --noconfirm


RUN pacman --noconfirm -Sy fastfetch micro linux-cachyos


LABEL containers.bootc="1"
LABEL ostree.bootable="1"

CMD ["/bin/bash"]
