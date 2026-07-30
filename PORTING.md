# Porting rules: keeping this fork rebaseable

This repository is a fork of [raspberrypi/rpi-imager](https://github.com/raspberrypi/rpi-imager).
Upstream is tracked as the `upstream` git remote; this branch is based on **v2.0.10**.

## Why this document exists

The previous fork was based on v1.9.6 and carried all Unraid work in a single 229-file commit
(+14,706 / −20,863). When upstream shipped v2.0.x, that fork could not be rebased — not because the
Unraid features were large (they are roughly 1,500 lines), but because the fork had also:

- renamed `rpi-imager` → `unraid-usb-creator` across filenames, the CMake target, the QML module URI,
  and every `i18n/*.ts` file;
- reformatted upstream `.cpp` files wholesale — and inconsistently, with Allman braces applied to
  `oslistmodel.cpp` / `imagewriter.cpp` and LLVM 2-space applied to `downloadextractthread.cpp` /
  `downloadthread.cpp`;
- deleted 20+ upstream translations and replaced them with four hand-maintained ones;
- committed build artifacts (`debian/unraid-usb-creator/`, including a compiled binary).

Each of those produces a conflict on nearly every upstream file, on every future upstream bump. The
Unraid features were never the problem. **Do not reintroduce any of them.**

## The three rules

### 1. Never rename or reformat an upstream file

- The CMake project stays `rpi-imager`. The QML module URI stays `RpiImager`. Translation files stay
  `src/i18n/rpi-imager_*.ts`.
- Product-facing naming comes from bundle metadata and `OUTPUT_NAME` (see the branding layer below),
  not from the source tree. Users never see the internal target name.
- Keeping upstream `i18n` filenames means we inherit all 24 upstream translations for free instead of
  maintaining four by hand.
- `.clang-format` in the repo root matches upstream style and sets `ColumnLimit: 0` so no tool
  re-wraps upstream lines. Do not run a formatter across upstream files.

### 2. New Unraid code is additive, under `src/unraid/`

New files, its own `.qrc`, its own wizard step. Additive files never conflict on rebase.

### 3. Patches to upstream files are a budget, not a habit

Every edit to an upstream file carries a `// UNRAID:` marker comment (`# UNRAID:` in CMake,
`// UNRAID:` in QML). This makes the entire fork surface enumerable:

```bash
git grep -n "UNRAID:"
```

Before adding a new patch to an upstream file, check whether the change can live in `src/unraid/`
instead, or whether it is generic enough to send upstream as a PR.

## Branding layer

`src/cmake/UnraidBranding.cmake` defines the product identity as cache variables that default to
upstream's values. The platform packaging files read those variables instead of hardcoding strings:

| Variable | Purpose |
|---|---|
| `IMAGER_APP_NAME` | Display name ("Unraid USB Creator") |
| `IMAGER_EXE_NAME` | Installed executable / bundle name |
| `IMAGER_BUNDLE_ID` | macOS bundle identifier, Linux desktop-file id |
| `IMAGER_VENDOR` | Copyright holder |
| `IMAGER_ICON_*` | Per-platform icon paths |

This is deliberately small and generic — it is a change we could reasonably offer upstream.

### Two rules that keep it from drifting

Branding is roughly a third of our entire upstream patch surface, and it is where our worst
shipped bug came from, so it has structure rather than convention holding it together.

**The rename is applied in exactly one place.** `unraid_apply_branding(<target>)` in
`UnraidBranding.cmake`, called once from `src/CMakeLists.txt` right after `add_executable`. Do
not add `set_target_properties(... OUTPUT_NAME ...)` to a platform packaging file. Each platform
used to do its own, Linux was never given one, and the result was an AppImage whose `AppRun`
looked for a binary that had been installed under the upstream target name — built green, dead on
first launch. One call site makes "renamed on two platforms out of three" unrepresentable.

macOS intentionally gets `IMAGER_APP_NAME` where the others get `IMAGER_EXE_NAME`: `OUTPUT_NAME`
names the `.app` directory and Finder shows that rather than `CFBundleName`, so it wants the
display name with spaces. That difference lives inside the function.

**Packaging scripts read the identity, they never declare it.** `UnraidBranding.cmake` generates
`branding.env` into the build tree (see `cmake/branding.env.in`); `create-appimage.sh` sources it
after configuring and derives everything — AppRun's exec target, the desktop file, the output
filename — from those values. It previously kept its own hardcoded copies of the exe name and
desktop id, which is how it and the build came to disagree about what the binary was called.

The same pattern already existed for the Windows installer templates
(`installer_extra_vars.cmake`) and for C++ (`branding.h`). If a new script needs a product name,
extend `branding.env.in` — do not re-declare it.

To build stock upstream, set the brand, never the individual names:

```bash
IMAGER_BRAND=rpi ./create-appimage.sh     # derives Raspberry_Pi_Imager / rpi-imager
```

**Assert the artefact, not the intent.** A name that is merely *computed* correctly proves
nothing; the check that matters is that the thing the launcher points at exists.
`create-appimage.sh` fails the build if `AppRun`'s exec target is missing, and
`create_styled_dmg.sh` fails if the `.app` bundle is not where it expects. Both bugs above would
have been caught by the former. Keep that habit for any new packaging path.

## Rebasing onto a new upstream release

```bash
git fetch upstream --tags
git rebase <new-tag>
```

`git rerere` is enabled for this repo, so conflict resolutions you have already made are replayed
automatically on subsequent attempts.

After rebasing:

1. `git grep -n "UNRAID:"` — confirm every marked patch survived and still makes sense.
2. `git diff <new-tag> --stat -- src` — the upstream-file portion should stay small. If it has grown,
   something got reformatted or renamed; find it and revert that part.
3. Build and run the macOS smoke test (below).

## Expected patch surface

Upstream files we intentionally modify:

| File | Change |
|---|---|
| `src/CMakeLists.txt` | include branding layer; add `src/unraid` sources + qrc |
| `src/config.h` | OS-list / telemetry / GUID-validation URLs |
| `src/Style.qml` | colour values only (Unraid dark theme) — no structural change |
| `src/drivelist/drivelist.h`, `drivelist_{darwin.mm,linux.cpp,windows.cpp}` | restore `vid` / `pid` / `serialNumber` on `DeviceDescriptor` |
| `src/drivelistitem.{h,cpp}`, `src/drivelistmodel.{h,cpp}` | `guid` / `guidValid` properties and model roles |
| `src/downloadextractthread.cpp` | single post-extract hook into `src/unraid/` |
| `src/driveformatthread.{h,cpp}` | plumb the FAT32 volume label (`UNRAID`) |
| `src/mac/PlatformPackaging.cmake` and siblings | read branding variables |
| `src/oslistmodel.{h,cpp}` | `contains_multiple_files` role — without it Unraid writes as a raw image |
| `src/wizard/WizardContainer.qml` | brand-gated step list, routes two slots at Unraid steps |
| `src/wizard/StorageSelectionStep.qml` | USB-only filter, GUID badge |
| `src/wizard/HostnameCustomizationStep.qml` | server-name wording |
| `src/wizard/{DeviceSelectionStep,OSSelectionStep,LanguageSelectionStep,DoneStep}.qml`, `src/main.qml`, `src/CommonStrings.qml` | product name via `ImageWriter::appName()` instead of a literal |

Everything else Unraid-specific lives in `src/unraid/`.

As of the v2.0.10 port this is **36 files, ~850 insertions / ~100 deletions** against
upstream. The deletion count is the number that matters: the v1.9.6 fork deleted 20,863
lines from upstream files. If a future rebase makes that number jump, something has been
reformatted or renamed — find it and revert that part rather than resolving it by hand.

## Traps worth knowing about

**Wizard steps must commit as the user types, not in `onNextClicked`.**
`WizardContainer.nextStep()` calls `applyCustomisationFromSettings()` on entering the
writing step, and the instantiation-site `onNextClicked: root.nextStep()` races with the
step's own handler. A step that only commits on Next will have its values silently
dropped while the summary still reports them as configured. See
`src/unraid/wizard/UnraidNetworkStep.qml`.

**Do not hand the write thread `getSavedCustomisationSettings()`.**
That is the QSettings-persisted map, which holds only what individual steps chose to
persist. It is not the wizard's session map. Passing it overwrites the real settings with
a near-empty one — the bug that made static addressing and Wi-Fi vanish while the server
name still worked.

### Windows: four things upstream gets away with and we do not

None of these are reachable from a Mac. All four were found in one session of testing in
a Windows VM with a USB drive passed through, and all four would come straight back if a
future rebase dropped the marked patches. Test on Windows before shipping.

**A UASP drive is not "USB" to upstream's classifier.** `drivelist_windows.cpp` derives
`isUSB` from the device *enumerator*, and Windows drives UASP bridges (most USB3
enclosures, plenty of ordinary sticks) through `SCSI\`, not `USBSTOR\`. Upstream notices
this as `isUAS` but computes it *after* the checks that need it. Consequences: our
`usbOnlyStorage` filter hides the drive, the GUID derivation is gated on `isUSB` so it
gets none anyway, and the "non-removable on a generic driver" system-drive guess hides it
a second time. Symptom is a completely empty storage step. Fixed by folding UAS into
`isUSB` right after the bus-type refinement.

**Windows prefixes `MSFT30` to the instance-id serial.** Any device advertising the
Microsoft OS descriptor — UASP bridges do — enumerates as
`USB\VID_174C&PID_55AA\MSFT30123456794AA4`. macOS (IOKit) reports the bare serial, and so
does the authority we have to match (see below). Because `strncpy_guid()` right-aligns the
serial into a 16-char field and *discards from the beginning* when it overflows, the
6-char prefix does not produce anything obviously malformed — it quietly shifts the real
serial out of the top: `MSFT30123456794AA4` (18) becomes `FT30123456794AA4`, i.e.
`174C-55AA-FT30-123456794AA4` instead of `174C-55AA-0000-123456794AA4`. The stick writes
and boots perfectly and only the licence fails to validate. Strip it.

### What the GUID must match, exactly

`unraidd` does **not** read the udev database for the block device. `get_flash_info()`
(`regis.c`) shells out to:

```
/sbin/udevadm test-builtin usb_id <syspath-of-/sys/block/sdX>
```

and takes `ID_VENDOR_ID` (width 4), `ID_MODEL_ID` (width 4) and `ID_SERIAL_SHORT`
(width 16) from *that* output, normalising each through `strncpy_guid()`: strip blanks,
uppercase, left-pad `'0'` when short, discard the leading excess when long.

This distinction matters and is easy to get wrong. Querying `udevadm info` on the block
device can report something completely different — on a SAT-capable UAS bridge the
persistent-storage rules run `ata_id` and store the *inner* drive's identifiers
(`ID_BUS=ata`, the SSD's ATA serial, no `ID_VENDOR_ID` at all). Forcing the `usb_id`
builtin bypasses all of that and reads the USB descriptor, which is exactly why the GUID
is stable regardless of what bridge chip is in the enclosure — and why our reading the USB
descriptor on each platform is the right thing to do.

Verified on an ASMT 2115 enclosure: `udevadm test-builtin usb_id` gives
`ID_VENDOR_ID=174c`, `ID_MODEL_ID=55aa`, `ID_SERIAL_SHORT=123456794AA4` →
`174C-55AA-0000-123456794AA4`, matching what the creator displays on macOS and Windows.
To check parity by hand on a booted server, run that command rather than `udevadm info`.

**Raw sector writes need an explicit partition-table rescan.** `DiskFormatter` lays down
the MBR and FAT32 boot sector by writing sectors directly, which Windows does not notice —
it still believes the disk is blank from the preceding `diskpart clean`, so no volume is
created and no drive letter assigned. Upstream's format flow ends there so it never cares;
ours continues into `extractMultiFileRun()`, which needs a mounted drive letter. Symptom is
"Operating system did not mount FAT32 partition" on a disk `Get-Partition` reports as
having no partitions at all — which reads like the format failed when only Windows' view
of it is stale. Call `DiskpartUtil::rescanDisk()` after a successful format.

**The FAT volume label needs a root-directory entry, not just `BS_VolLab`.** The boot
sector field is the legacy copy; every OS reports the label from a root-directory entry
carrying `ATTR_VOLUME_ID`. Without it `blkid` says `LABEL_FATBOOT` instead of `LABEL`,
udev sets no `ID_FS_LABEL`, `/dev/disk/by-label/UNRAID` never appears, and Windows
`vol` says "has no label" — which is what `make_bootable.bat` gates on.

Related: **`make_bootable` is never run for the user, deliberately.** Every failure path
in that script prints a message and then `goto:end`, exiting with errorlevel 0, so a
checked exit code proves nothing. UEFI boot comes from `EFI/boot/` in the release, so the
drive boots as written; the legacy BIOS boot sector is opt-in and the Done step names the
script. Do not reintroduce an automatic call.

## Building on macOS (development)

Upstream's release path builds a trimmed Qt via `qt/build-qt-macos.sh`. For local iteration,
Homebrew Qt is much faster and is what these instructions assume.

`src/unraid/tools/dev.sh` wraps the flags below so they do not have to be retyped:

```bash
brew install qt
./src/unraid/tools/dev.sh build      # configure + build
./src/unraid/tools/dev.sh run --dev  # build, then run with the small dev image
./src/unraid/tools/dev.sh dmg        # build the DMG
./src/unraid/tools/dev.sh test       # unit tests
./src/unraid/tools/dev.sh rpi        # confirm the stock upstream build still configures
```

The underlying commands, if you would rather run them directly:

```bash
cmake -S src -B build -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_PREFIX_PATH=/opt/homebrew/opt/qt \
  -DCMAKE_OSX_ARCHITECTURES=arm64
cmake --build build -j 8
open "build/Unraid USB Creator.app"
```

The bundle is named from `IMAGER_APP_NAME`, so it is `Unraid USB Creator.app` even though the CMake
target is still `rpi-imager`. Finder shows the .app directory name rather than `CFBundleName`, so it
has to carry the spaces; Windows and Linux use `IMAGER_EXE_NAME` instead, where spaces are unwelcome.

`CMAKE_OSX_ARCHITECTURES=arm64` is required: upstream defaults to a universal `arm64;x86_64` build,
and Homebrew's Qt is single-architecture, so the universal link fails.

### Iterating on the write path

A real Unraid release is a ~1.1 GB download, which makes testing the write path slow. Build a small
stand-in and point `UNRAID_DEV_IMAGE` at it — it appears as an extra OS entry and exercises the same
code path (FAT32 format → multi-file extract → `unraid_postwrite`) in seconds:

```bash
./src/unraid/tools/make-dev-image.sh
UNRAID_DEV_IMAGE=$PWD/build/unraid-dev-image.zip open "build/Unraid USB Creator.app"
```

The entry only exists while the variable is set. The image is not bootable and must never reach a user.

Note that each write needs a macOS admin authorisation prompt, since it opens the raw device. Upstream
ships an "Install system authorization" helper that would remove the repeated prompting; wiring that up
is worth doing before any long testing session.

### Verifying a write actually applied

`unraid_postwrite.cpp` logs what it did, which matters because the drive auto-ejects on completion and
cannot be re-read without a replug:

```
Unraid: finalising flash drive at "/Volumes/UNRAID" with 12 customisation setting(s)
Unraid: setting server name to "full-verify"
Unraid: configuring Wi-Fi network "HomeNet5G" security "PSK" region "US"
```

A setting count of 1 when you configured more than the server name means the map was clobbered — see
the second trap above.

## Releasing

Push a tag; `.github/workflows/release.yml` builds all three installers signed and
attaches them to a GitHub Release:

```bash
git tag v2.0.10-unraid.1
git push origin v2.0.10-unraid.1
```

The tag name is also the version the app reports, because the build derives it from
`git describe` — so tag names are user-visible. A tag containing `-rc` or `-beta` is
published as a pre-release.

Release reuses `build.yml` via `workflow_call` rather than duplicating it, so CI and
release cannot drift. `build.yml` alone (push/PR) produces the same artifacts unsigned.

### What CI does not reimplement

Packaging is upstream's, driven by the branding variables:

| Platform | Command | Output |
|---|---|---|
| macOS | `cmake --build build --target dmg` | `Unraid USB Creator-<version>.dmg` |
| Windows | `cmake --build build --target inno_installer` | `installer/unraid-usb-creator-<version>.exe` |
| Linux | `./create-appimage.sh` | `*.AppImage` |

Signing is flags, not workflow steps: `-DIMAGER_SIGNED_APP=ON`,
`-DIMAGER_SIGNING_IDENTITY=…`, `-DIMAGER_NOTARIZE_APP=ON`,
`-DIMAGER_NOTARIZE_KEYCHAIN_PROFILE=…`. The old fork hand-rolled `codesign`,
`create-dmg`, `notarytool` and `stapler` as ~60 lines of workflow; all of that is
now one target.

### Secrets

The macOS secret names are unchanged from the old pipeline, so existing repository
secrets keep working:

`APPLE_BUILD_CERTIFICATE_BASE64`, `APPLE_BUILD_CERTIFICATE_PASSWORD`,
`APPLE_KEYCHAIN_PASSWORD`, `APPLE_SIGNING_KEY_ID`, `APPLE_EMAIL_ADDRESS`,
`APPLE_APP_PASSWORD`, `APPLE_TEAM_ID`.

### Windows code signing

The Windows job signs via **Azure Artifact Signing** (renamed from Trusted Signing in
January 2026) and is wired but **dormant**: with the secrets unset it builds unsigned
exactly as before and warns in the job summary. Nothing fails.

Set these six repository secrets to activate it:

| Secret | Where it comes from |
|---|---|
| `AZURE_SIGNING_TENANT_ID` | Entra tenant (directory) ID |
| `AZURE_SIGNING_CLIENT_ID` | App registration (service principal) client ID |
| `AZURE_SIGNING_CLIENT_SECRET` | Client secret for that app registration |
| `AZURE_SIGNING_ENDPOINT` | Region endpoint, e.g. `https://wus2.codesigning.azure.net` — must match the region the Signing Account was created in |
| `AZURE_SIGNING_ACCOUNT` | Artifact Signing account name |
| `AZURE_SIGNING_PROFILE` | Certificate profile name |

The service principal needs the **Code Signing Certificate Profile Signer** role on
the Signing Account, or every call returns 403.

**Order matters, and it is not the obvious one.** The application binary is signed
*before* Inno packages it, and the installer is signed *after*. Signing only the
installer leaves an unsigned executable inside it — and that inner binary is what the
user actually runs, so it is what SmartScreen judges and what supplies the UAC
publisher string. Do not collapse these into one step.

`IMAGER_SIGNED_APP` is deliberately **not** set on this path. That switch drives
upstream's `signtool sign /a`, which selects a certificate from the Windows store;
Artifact Signing has no importable certificate at all — the key lives in Microsoft's
HSM and signing is a service call. The two mechanisms are mutually exclusive.

A "Verify signature" step runs `Get-AuthenticodeSignature` and fails the build unless
the status is `Valid`. The signing action exiting zero is not sufficient evidence: a
signature can be present but untrusted, which still ships a binary users get warned
about.

Since June 2023 the CA/Browser Forum requires code-signing keys on FIPS 140-2 Level 2
hardware, so a newly issued certificate cannot be a bare PFX — the old
`WINDOWS_CERT_BASE64` approach only ever worked for a certificate you already held.
Alternatives if Azure proves impractical: Certum Open Source (~€30/yr, but the
certificate names an individual rather than the company) or DigiCert / SSL.com cloud
signing. Each replaces only the two signing steps; Configure and Build are unchanged.

**Azure gotcha worth knowing before committing to it:** the certificate subject is
taken from the Azure *billing account*, and a billing account whose `accountType` is
`Individual` can only ever validate an individual identity — it cannot produce a
`Lime Technology, Inc.` certificate. That type is fixed when the billing account is
created and cannot be changed afterwards, so the account must be signed up as an
organisation from the start, with the legal name matching the business registration
exactly. Check with:

```bash
az rest --method get --url "https://management.azure.com/providers/Microsoft.Billing/billingAccounts/<id>?api-version=2020-05-01" \
  --query "properties.{type:accountType,soldTo:soldTo.companyName}"
```

Updating the sold-to name alone does **not** change `accountType` — the portal will
happily show the new company name while the gating field stays `Individual`.

Note that OV certificates do not immediately silence SmartScreen; reputation accrues
with download volume. Only EV gets instant reputation, and EV needs a hardware token
(self-hosted runner) or a pricier cloud tier.

### Windows: native rather than MXE

The old pipeline cross-compiled from Linux with a custom MXE image
(`ghcr.io/unraid/usb-creator-next/qt6-mxe-env`) and packaged with NSIS. That image is
pinned to the Qt that v1.9.6 wanted, while upstream 2.0 needs Qt 6.9+, bundles libusb
and builds a second `callback-relay` executable. CI therefore uses a native
`windows-latest` runner with MinGW and Inno Setup, which is the combination upstream
actually tests. Revisiting MXE later is a cost optimisation, not a correctness fix.
