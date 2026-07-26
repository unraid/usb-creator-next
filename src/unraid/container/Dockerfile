# UNRAID: Games-on-Whales / Wolf app image, so the USB Creator can be launched
# from Unraid Bigscreen and streamed over Moonlight.
#
# Built on the GOW base image, which supplies the Wayland/Sway session, the
# audio bridge and the /dev wiring Wolf expects. Firefox and RetroArch in the
# same Wolf config are built the same way.
#
# IMPORTANT — this app is not like the other Bigscreen apps. It writes raw block
# devices, so:
#   * the USB stick must be plugged into the SERVER, not the streaming client;
#   * the container needs block-device access that Firefox et al. do not (see
#     wolf-app.toml).
# Read src/unraid/container/README.md before deploying it.

ARG GOW_BASE=ghcr.io/games-on-whales/base-app:edge
FROM ${GOW_BASE}

# AppImage to bake in. Pass a released asset, e.g.
#   --build-arg APPIMAGE_URL=https://github.com/unraid/usb-creator-next/releases/download/<tag>/<file>.AppImage
ARG APPIMAGE_URL=""

USER root

# util-linux: drivelist_linux enumerates via lsblk, so without it no drives appear.
# udev + eject: mount/eject handling around the write.
# dosfstools: the FAT32 format step shells out on Linux.
RUN apt-get update && apt-get install -y --no-install-recommends \
        util-linux \
        udev \
        eject \
        dosfstools \
        ca-certificates \
        curl \
        libfuse2 \
    && rm -rf /var/lib/apt/lists/*

# Extract rather than run the AppImage directly: FUSE inside a container needs
# privileges we would rather not grant just to mount a squashfs at startup.
RUN set -eux; \
    if [ -z "${APPIMAGE_URL}" ]; then \
        echo "APPIMAGE_URL build-arg is required" >&2; exit 1; \
    fi; \
    curl -fsSL "${APPIMAGE_URL}" -o /tmp/app.AppImage; \
    chmod +x /tmp/app.AppImage; \
    cd /opt; \
    /tmp/app.AppImage --appimage-extract >/dev/null; \
    mv squashfs-root unraid-usb-creator; \
    rm -f /tmp/app.AppImage; \
    ln -s /opt/unraid-usb-creator/AppRun /usr/local/bin/unraid-usb-creator

COPY startup.sh /opt/gow/startup-app.sh
RUN chmod +x /opt/gow/startup-app.sh

# Matches how the GOW images launch their app under the provided compositor.
ENV RUN_SWAY=1 \
    GAMESCOPE_WIDTH=1920 \
    GAMESCOPE_HEIGHT=1080

# Deliberately no `USER retro`: the GOW base creates that account at runtime in
# /etc/cont-init.d/10-setup_user.sh, so naming it at build time fails with
# "unable to find user retro". The base entrypoint drops privileges itself.
