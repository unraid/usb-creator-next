# Unraid USB Creator — Bigscreen container

Packages the Linux AppImage as a Games-on-Whales app so it can be launched from
Unraid Bigscreen and streamed over Moonlight, alongside Firefox / RetroArch /
Steam in the same Wolf config.

## Read this first

This app is not like the other Bigscreen apps. It writes **raw block devices**.

1. **The USB stick must be plugged into the server.** Moonlight forwards input
   and video, not USB storage — a stick in the TV client is invisible here.
2. **The container gets broad block-device access.** `DeviceCgroupRules` grants
   block-major 8 (`sd*`) and 259 (`nvme*`), so it can in principle write to
   array disks. The app's USB-only filter is a UI convenience, not a security
   boundary. Narrow the rules if that is too broad for your setup.

If neither is acceptable, run the AppImage directly on the host — it is the same
binary, without the container's device exposure.

## Build

```bash
docker build \
  --build-arg APPIMAGE_URL=https://github.com/unraid/usb-creator-next/releases/download/<tag>/<file>.AppImage \
  -t ghcr.io/unraid/usb-creator-bigscreen:latest \
  src/unraid/container
```

The AppImage is baked in rather than downloaded at runtime, so the image is
reproducible and works on a server with no outbound access.

## Install into Wolf

Append `wolf-app.toml` to the `[[profiles]]` block in
`/mnt/user/appdata/gow/cfg/config.toml` on the server, keeping the indentation —
Wolf nests apps under a profile. Then restart the `wolf` container.

## Things that bit us, so they do not bite you again

**No `USER retro` in the Dockerfile.** The GOW base creates that account at
runtime in `/etc/cont-init.d/10-setup_user.sh`. Naming it at build time fails
with `unable to find user retro`. The base entrypoint drops privileges itself.

**The `/dev` bind is plain, not `:rslave`.** Unraid's `/dev` is not a shared or
slave mount, so Docker rejects `rslave` with *"path /dev is mounted on /dev but
it is not a shared or slave mount"*. The trade-off is that devices hot-plugged
after the container starts may not appear — plug the stick in before launching.

**The AppImage is extracted, not executed.** Running it directly needs FUSE,
which needs privileges we would rather not grant just to mount a squashfs.
`--appimage-extract` at build time avoids that entirely.

**`util-linux` is required.** Drive enumeration goes through `lsblk`; without it
the storage step is silently empty. `startup.sh` warns if `/dev/disk/by-id` is
missing, which is the usual symptom of the container not getting host devices.

## Verified so far

On the server (`docker build` + `docker run`):

- image builds from `ghcr.io/games-on-whales/base-app:edge`
- `AppRun`, `lsblk`, `eject` and `mkfs.vfat` are all present
- with `-v /dev:/dev`, the container's `lsblk` output matches the host's exactly

**Not yet verified:** launching through Wolf and streaming it to a client, and
actually writing a stick from inside the container. The Wolf app entry has not
been added to a live `config.toml`.
