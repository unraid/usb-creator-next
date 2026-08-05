/*
 * SPDX-License-Identifier: Apache-2.0
 * Copyright (C) 2026 Lime Technology, Inc.
 *
 * Post-extraction customisation for Unraid flash drives.
 */

#ifndef UNRAID_POSTWRITE_H
#define UNRAID_POSTWRITE_H

#include <QString>
#include <QVariantMap>

namespace Unraid {

/** Init-format marker identifying an Unraid multi-file image. */
inline constexpr const char *kInitFormat = "UNRAID";

/**
 * @brief Finish an Unraid flash drive after its zip has been extracted.
 *
 * Unraid does not ship a disk image. It ships a zip of files that is extracted
 * onto a freshly-formatted FAT32 volume, after which the drive still has to be
 * made bootable and have its config files personalised. That is what this does:
 *
 *   1. patch `config/ident.cfg`   — server name
 *   2. patch `config/network.cfg` — DHCP or static addressing
 *   3. patch `config/wireless.cfg` — Wi-Fi, when configured
 *   4. restore `syslinux/` and the `make_bootable*` helpers from our resources,
 *      for releases whose zip omits them
 *
 * Note that `make_bootable` is deliberately never run for the user, on any
 * platform. It installs the legacy BIOS boot sector; UEFI boot comes from
 * `EFI/boot/` in the release itself, so the drive this produces boots on modern
 * hardware without it. Users who need BIOS boot run the script themselves, and
 * the Done step tells them how.
 *
 * @param mountPoint  Directory the FAT32 volume is mounted at.
 * @param settings    Wizard customisation values (servername, dhcp, ipaddr, ...).
 * @param errorOut    Set to a human-readable message when the call fails.
 * @return true on success.
 */
bool finalizeFlashDrive(const QString &mountPoint,
                        const QVariantMap &settings,
                        QString *errorOut);

/**
 * @brief Set `key=value` in an Unraid-style cfg buffer, or remove the key.
 *
 * Unraid cfg files are `KEY="value"` lines. Existing keys are rewritten in place
 * so unrelated settings and ordering survive; absent keys are appended.
 *
 * Exposed for unit testing.
 */
QString setCfgKey(const QString &contents, const QString &key, const QString &value);
QString removeCfgKey(const QString &contents, const QString &key);

} // namespace Unraid

#endif // UNRAID_POSTWRITE_H
