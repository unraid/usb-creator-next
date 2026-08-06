# USB Creator QEMU end-to-end test

This test runs the Linux Unraid USB Creator inside an Ubuntu QEMU guest. QEMU
presents a sparse host file to the guest through an emulated xHCI controller and
`usb-storage` device. The Creator therefore discovers a real USB bus device,
formats it, extracts the development image, and finalises the Unraid files.

The flow deliberately mirrors the evidence and cleanup rules used by Limetech's
browser E2E suite, but it is not a `core-ui-test` Playwright journey. USB Creator
is a native Qt application, so the guest drives its accessibility tree with
Dogtail and captures each meaningful state as a PNG.

## What it proves

1. The packaged Linux application launches in a clean machine.
2. A QEMU USB mass-storage device is discovered and is the only writable target.
3. The development ZIP takes the production multi-file write path.
4. The target is reformatted as FAT32 and labelled `UNRAID`.
5. The expected release payload and post-write configuration exist afterward.
6. The VM and disposable target are stopped on success or failure.

The host verifier reads the raw target only after QEMU exits. It never mounts or
writes a host disk.

## Run

Prerequisites on an Ubuntu host:

```bash
sudo apt-get install qemu-system-x86 qemu-utils cloud-image-utils mtools parted openssh-client
```

Build the AppImage and development image, then run:

```bash
./src/unraid/tools/make-dev-image.sh
e2e/qemu/run.sh \
  --appimage ./unraid-usb-creator*.AppImage \
  --dev-image build/unraid-dev-image.zip
```

The first run downloads and verifies Ubuntu's current Noble cloud image. Set
`USB_CREATOR_E2E_CACHE` to keep it somewhere other than
`~/.cache/unraid-usb-creator-e2e`.

Successful evidence is written under a timestamped `build/e2e-qemu/run-*`
directory so a failed retry cannot reuse stale screenshots:

```text
run-YYYYMMDDTHHMMSSZ-PID/
  qemu.log
  manifest.jsonl
  screenshots/
    01-os-selection.png
    02-storage-selection.png
    03-write-summary.png
    04-write-complete.png
  target.raw
```

`target.raw` is sparse and is retained for diagnosis. It is never uploaded by
the workflow; only logs, the captioned `shot()` manifest, and screenshots are
uploaded.

## Safety boundary

The runner refuses to start unless every mutable disk path is inside its newly
created temporary directory. The guest receives only its copy-on-write system
disk and the newly created target image. No host block device is passed through.

## macOS coverage

This flow exercises the shared format, extract, customisation, and finalisation
path. It does not claim to test macOS Disk Arbitration, the authorization
dialog, or physical-device eject behavior. QEMU cannot inject an emulated USB
device into a host macOS process. Those behaviors still require a physical USB
stick, a USB-gadget device, or a separately maintained macOS guest environment.
