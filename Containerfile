#                                            ☆ﾟ.*･｡ﾟ Frankenblue (fork of XeniaOS) ﾟ｡･*.ﾟ☆
#                                        Arch/CachyOS Bootc | Gaming On Linux | Bazaar | Flatpaks
#                                   
#   
#
#
#                                   
#                                                                 Credits:
#               the talented Xenia Meraki (the transfem package fox) | the wise @tulilirockz (who saved the distro)
# 
#

FROM docker.io/cachyos/cachyos-v3:latest

ENV DEV_DEPS="base-devel git rust"

ENV DRACUT_NO_XATTR=1



########################################################################################################################################
# Pre-setup | We do some system maintenance tasks + Set up some things for the rest of the containerfile to go smoothly. ###############
########################################################################################################################################

# Set it up such that pacman will automatically clean package cache after each install
# So that we don't run out of memory in image generation and don't need to append --clean after everything
# ALSO DO NOT APPEND --CLEAN TO ANYTHING :D
RUN echo -e "[Trigger]\n\
Operation = Install\n\
Operation = Upgrade\n\
Type = Package\n\
Target = *\n\
\n\
[Action]\n\
Description = Cleaning up package cache...\n\
Depends = coreutils\n\
When = PostTransaction\n\
Exec = /usr/bin/rm -rf /var/cache/pacman/pkg" | tee /usr/share/libalpm/hooks/package-cleanup.hook

########################################################################################################################################
# Package Installs #####################################################################################################################
########################################################################################################################################

# Initialize the database
RUN pacman -Syu --noconfirm

# Use the Arch mirrorlist that will be best at the moment for both the containerfile and user too! Fox will help!
RUN pacman -S --noconfirm reflector

# Base packages \ Linux Foundation \ Foss is love, foss is life! We split up packages by category for readability, debug ease, and less dependency trouble
RUN pacman -S --noconfirm base base-devel dracut linux-firmware ostree systemd btrfs-progs e2fsprogs xfsprogs binutils dosfstools skopeo dbus dbus-glib glib2 shadow

# Media/Install utilities/Media drivers
RUN pacman -S --noconfirm librsvg libglvnd qt6-multimedia-ffmpeg plymouth acpid ddcutil dmidecode mesa-utils ntfs-3g \
      vulkan-tools wayland-utils playerctl

# Fonts
RUN pacman -S --noconfirm noto-fonts noto-fonts-cjk noto-fonts-emoji

# CLI Utilities
RUN pacman -S --noconfirm sudo bash bash-completion fastfetch btop jq less lsof nano openssh powertop man-db \
      tree usbutils vim wget wl-clipboard unzip ptyxis glibc-locales tar udev starship tuned-ppd tuned hyfetch docker podman curl

# Drivers
RUN pacman -S --noconfirm amd-ucode intel-ucode efibootmgr shim mesa lib32-mesa libva-intel-driver libva-mesa-driver \
      vpl-gpu-rt vulkan-icd-loader vulkan-intel vulkan-radeon apparmor xf86-video-amdgpu lib32-vulkan-radeon 

# Network / VPN / SMB / storage
RUN pacman -S --noconfirm libmtp networkmanager-openconnect networkmanager-openvpn nss-mdns samba smbclient networkmanager firewalld udiskie \
      udisks2 firewalld

# Accessibility
RUN pacman -S --noconfirm espeak-ng orca

# Pipewire
RUN pacman -S --noconfirm pipewire pipewire-pulse pipewire-zeroconf pipewire-ffado pipewire-libcamera sof-firmware wireplumber


# Add Maple Mono font, it's so cute! It's a pain to download! You'll love it.
RUN mkdir -p "/usr/share/fonts/Maple Mono" \
      && curl -fSsLo "/tmp/maple.zip" "$(curl "https://api.github.com/repos/subframe7536/maple-font/releases/latest" | jq '.assets[] | select(.name == "MapleMono-Variable.zip") | .browser_download_url' -rc)" \
      && unzip "/tmp/maple.zip" -d "/usr/share/fonts/Maple Mono"


# Place logo at plymouth folder location to appear on boot and shutdown.
#RUN wget -O /usr/share/plymouth/themes/spinner/watermark.png https://raw.githubusercontent.com/XeniaMeraki/XeniaOS-G-Euphoria/refs/heads/main/xeniaos_textlogo_plymouth_delphic_melody.png

RUN echo -ne '[Daemon]\nTheme=spinner' > /etc/plymouth/plymouthd.conf

########################################################################################################################################
# Set up bootc dracut | I think it sets up the bootc initial image / Compiles Bootc Package ############################################
########################################################################################################################################

# Workaround due to dracut version bump, please remove eventually
# FIXME: remove
RUN printf "systemdsystemconfdir=/etc/systemd/system\nsystemdsystemunitdir=/usr/lib/systemd/system\n" | tee /etc/dracut.conf.d/fix-bootc.conf

RUN --mount=type=tmpfs,dst=/tmp --mount=type=tmpfs,dst=/root \
    pacman -S --noconfirm base-devel git rust && \
    git clone https://github.com/bootc-dev/bootc.git /tmp/bootc && \
    make -C /tmp/bootc bin install-all install-initramfs-dracut && \
    sh -c 'export KERNEL_VERSION="$(basename "$(find /usr/lib/modules -maxdepth 1 -type d | grep -v -E "*.img" | tail -n 1)")" && \
    dracut --force --no-hostonly --reproducible --zstd --verbose --add ostree --kver "$KERNEL_VERSION"  "/usr/lib/modules/$KERNEL_VERSION/initramfs.img"'


########################################################################################################################################
# Flatpaks preinstalls | We love containers, flatpaks, and protecting installs from breaking! ##########################################
########################################################################################################################################

RUN mkdir -p /usr/share/flatpak/preinstall.d/

# Bazaar
RUN printf "[Flatpak Preinstall io.github.kolunmi.Bazaar]\nBranch=stable\nIsRuntime=false" > /usr/share/flatpak/preinstall.d/Bazaar.preinstall


# Systemd flatpak preinstall service, thanks Zirconium
RUN echo -ne '[Unit]\n\
Description=Preinstall Flatpaks\n\
After=network-online.target\n\
Wants=network-online.target\n\
ConditionPathExists=/usr/bin/flatpak\n\
ConditionPathExists=!/var/lib/xeniaos/preinstall-finished\n\
Documentation=man:flatpak-preinstall(1)\n\
\n\
[Service]\n\
Type=oneshot\n\
ExecStart=mkdir -p /var/lib/xeniaos\n\
ExecStart=/usr/bin/flatpak preinstall -y\n\
ExecStart=touch /var/lib/xeniaos/preinstall-finished\n\
RemainAfterExit=true\n\
Restart=on-failure\n\
RestartSec=30\n\
\n\
StartLimitIntervalSec=600\n\
StartLimitBurst=3\n\
\n\
[Install]\n\
WantedBy=multi-user.target' > /usr/lib/systemd/system/flatpak-preinstall.service

RUN systemctl enable flatpak-preinstall.service

########################################################################################################################################
# Linux OS stuff | We set some nice defaults ###########################################################################################
########################################################################################################################################

# Add user to sudoers file for sudo, enable polkit
RUN echo "%wheel      ALL=(ALL:ALL) ALL" | tee -a /etc/sudoers
RUN systemctl enable polkit

# Set up zram, this will help users not run out of memory.
RUN echo -ne '[zram0]\nzram-size = min(ram, 8192)' >> /usr/lib/systemd/zram-generator.conf
RUN echo -ne 'enable systemd-resolved.service' >> usr/lib/systemd/system-preset/91-resolved-default.preset
RUN echo -ne 'L /etc/resolv.conf - - - - ../run/systemd/resolve/stub-resolv.conf' >> /usr/lib/tmpfiles.d/resolved-default.conf
RUN systemctl preset systemd-resolved.service

# Enable wifi, firewall, power profiles.
RUN systemctl enable NetworkManager firewalld

# OS Release and Update
RUN echo -ne 'NAME="XeniaOS"\n\
PRETTY_NAME="XeniaOS"\n\
ID=arch\n\
BUILD_ID=rolling\n\
ANSI_COLOR="38;2;23;147;209"\n\
HOME_URL="https://github.com/XeniaMeraki/XeniaOS"\n\
LOGO=archlinux-logo\n\
DEFAULT_HOSTNAME="XeniaOS"' > /etc/os-release

# Automounter Systemd Service for flash drives and CDs
RUN echo -ne '[Unit] \n\
Description=Udiskie automount \n\
PartOf=graphical-session.target \n\
After=graphical-session.target \n\
 \n\
[Service] \n\
ExecStart=udiskie \n\
Restart=on-failure \n\
RestartSec=1 \n\
\n\
[Install] \n\
WantedBy=graphical-session.target\n' > /usr/lib/systemd/user/udiskie.service

# Symlink Vi to Vim / Make it to where a user can use vi in terminal command to use vim automatically | Thanks Tulip
RUN ln -s ./vim /usr/bin/vi

# System-wide default application associations for filetype calls
RUN echo -ne '[Default Applications]\n\
text/plain=org.kde.kate.desktop\n\
application/json=org.kde.kate.desktop\n\
\n\
text/html=floorp.desktop\n\
\n\
video/mp4=haruna.desktop\n\
video/x-matroska=haruna.desktop\n\
video/webm=haruna.desktop\n\
video/quicktime=haruna.desktop\n\
\n\
audio/mpeg=org.kde.elisa.desktop\n\
audio/flac=org.kde.elisa.desktop\n\
audio/ogg=org.kde.elisa.desktop\n\
audio/wav=org.kde.elisa.desktop\n\
\n\
image/png=pinta.desktop\n\
image/jpeg=pinta.desktop\n\
image/gif=org.kde.gwenview.desktop\n\
\n\
application/zip=org.kde.ark.desktop\n\
application/x-rar=org.kde.ark.desktop\n\
application/x-tar=org.kde.ark.desktop\n\
\n\
[Added Associations]' > /etc/xdg/mimeapps.list

# FIXME A different attempt at fixing file associations once again, revisit this
# https://www.reddit.com/r/kde/comments/1bd313p/dolphin_not_recognizing_file_associations/
RUN curl -L https://raw.githubusercontent.com/KDE/plasma-workspace/master/menu/desktop/plasma-applications.menu /etc/xdg/menus/applications.menu

# ENV default exports, QT theming 
# Load shared objects immediately for better first time latency
# Apply OBS_VK to all vulkan instances for better OBS game capture, some other windows may come along for the ride
ENV QT_QPA_PLATFORMTHEME=qt6ct
ENV LD_BIND_NOW=1
ENV OBS_VKCAPTURE=1

# Set vm.max_map_count for stability/improved gaming performance
# https://wiki.archlinux.org/title/Gaming#Increase_vm.max_map_count
RUN echo -ne "vm.max_map_count = 2147483642" > /etc/sysctl.d/80-gamecompatibility.conf

# Automount removable disks to /media/ using udisks2
# https://wiki.archlinux.org/title/Udisks
RUN echo -ne 'ENV{ID_FS_USAGE}=="filesystem|other|crypto", ENV{UDISKS_FILESYSTEM_SHARED}="1"' > /etc/udev/rules.d/99-udisks2.rules

RUN echo -ne 'D /media 0755 root root 0 -' > /etc/tmpfiles.d/media.conf

########################################################################################################################################
# CachyOS settings | Since we have the CachyOS kernel, we gotta put it to good use #####################################################
########################################################################################################################################

# Activate NTSync, wags my tail in your general direction
RUN echo 'ntsync' > /etc/modules-load.d/ntsync.conf

# CachyOS bbr3 Config Option
RUN echo -ne 'net.core.default_qdisc=fq \n\
net.ipv4.tcp_congestion_control=bbr\n' > /etc/sysctl.d/99-bbr3.conf


########################################################################################################################################
# Final Bootc Setup. The horrors are endless. but we stay silly :3c -junoinfernal -maia arson crimew ###################################
########################################################################################################################################

# This fixes a user/groups error with Arch Bootc setup.
# FIXME Do NOT remove until fixed upstream. Script created by Tulip.

RUN mkdir -p /usr/lib/systemd/system-preset /usr/lib/systemd/system

RUN echo -ne '#!/bin/sh\ncat /usr/lib/sysusers.d/*.conf | grep -e "^g" | grep -v -e "^#" | awk "NF" | awk '\''{print $2}'\'' | grep -v -e "wheel" -e "root" -e "sudo" | xargs -I{} sed -i "/{}/d" $1' > /usr/libexec/xeniaos-group-fix
RUN chmod +x /usr/libexec/xeniaos-group-fix
RUN echo -ne '[Unit]\n\
Description=Fix groups\n\
Wants=local-fs.target\n\
After=local-fs.target\n\
[Service]\n\
Type=oneshot\n\
ExecStart=/usr/libexec/xeniaos-group-fix /etc/group\n\
ExecStart=/usr/libexec/xeniaos-group-fix /etc/gshadow\n\
ExecStart=systemd-sysusers\n\
[Install]\n\
WantedBy=default.target multi-user.target\n' > /usr/lib/systemd/eniaos-group-fix.service

RUN echo "enable xeniaos-group-fix.service" > /usr/lib/systemd/system-preset/01-xeniaos-group-fix.preset
RUN systemctl enable xeniaos-group-fix.service

# Necessary for general behavior expected by image-based systems
RUN sed -i 's|^HOME=.*|HOME=/var/home|' "/etc/default/useradd" && \
    rm -rf /boot /home /root /usr/local /srv && \
    mkdir -p /var /sysroot /boot /usr/lib/ostree && \
    ln -s var/opt /opt && \
    ln -s var/roothome /root && \
    ln -s var/home /home && \
    ln -s sysroot/ostree /ostree && \
    echo "$(for dir in opt usrlocal home srv mnt ; do echo "d /var/$dir 0755 root root -" ; done)" | tee -a /usr/lib/tmpfiles.d/bootc-base-dirs.conf && \
    echo "d /var/roothome 0700 root root -" | tee -a /usr/lib/tmpfiles.d/bootc-base-dirs.conf && \
    echo "d /run/media 0755 root root -" | tee -a /usr/lib/tmpfiles.d/bootc-base-dirs.conf && \
    printf "[composefs]\nenabled = yes\n[sysroot]\nreadonly = true\n" | tee "/usr/lib/ostree/prepare-root.conf"

RUN bootc container lint

#
#
# # TODO: 
# make it as slim as possible - to use as basis for other images
# add back the index
# remove existing silly text
# add my own silly text
# add logos and give the system a fun name
# proper credits and art
#
# # bonus:
# make it compatible so that others can use it
# a readable readme 
# make an option to use a different game launcher than steam?
# add containers out of the box?
# winboat out of the box? 
# waydtoid out of the box? 
