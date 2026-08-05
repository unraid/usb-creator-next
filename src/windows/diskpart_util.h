/*
 * SPDX-License-Identifier: Apache-2.0
 * Copyright (C) 2020 Raspberry Pi Ltd
 */

#ifndef DISKPART_UTIL_H
#define DISKPART_UTIL_H

#include <QString>
#include <QByteArray>
#include <QObject>
#include <chrono>
#include <functional>

namespace DiskpartUtil {

enum class VolumeHandling {
    SkipUnmounting,
    UnmountFirst
};

struct DiskpartResult {
    bool success;
    QString errorMessage;
};

// UNRAID: result of making the freshly formatted partition reachable through a
// filesystem path. See assignDriveLetter().
struct DriveLetterResult {
    bool success;
    QString mountPoint;   // e.g. "F:\\" — empty unless success is true
    bool assignedByUs;    // true when this call created the mount point
    QString errorMessage;
};

/**
 * Timing callback for performance instrumentation
 * Parameters: eventName, durationMs, success
 */
using TimingCallback = std::function<void(const QString&, quint32, bool)>;

/**
 * Cleans a Windows physical drive using diskpart utility (legacy method)
 * 
 * @param device - Windows physical drive path (e.g., "\\\\.\\PHYSICALDRIVE0")
 * @param timeout - Timeout for diskpart operation (default: 60 seconds)
 * @param maxRetries - Maximum number of retry attempts (default: 3)
 * @param volumeHandling - How to handle mounted volumes before diskpart (default: UnmountFirst)
 * @return DiskpartResult with success status and error message if failed
 */
DiskpartResult cleanDisk(const QByteArray &device, std::chrono::milliseconds timeout = std::chrono::seconds(60), int maxRetries = 3, VolumeHandling volumeHandling = VolumeHandling::UnmountFirst);

/**
 * Cleans a Windows physical drive using direct IOCTL calls (faster method)
 * 
 * This method is significantly faster than diskpart because it:
 * 1. Avoids spawning an external process
 * 2. Uses direct DeviceIoControl calls for partition table removal
 * 3. Has reduced sleep times (adaptive rather than fixed)
 * 
 * @param device - Windows physical drive path (e.g., "\\\\.\\PHYSICALDRIVE0")
 * @param timingCallback - Optional callback for performance event reporting
 * @return DiskpartResult with success status and error message if failed
 */
DiskpartResult cleanDiskFast(const QByteArray &device, TimingCallback timingCallback = nullptr);

/**
 * Unmount and lock all volumes on a physical drive
 *
 * @param device - Windows physical drive path (e.g., "\\\\.\\PHYSICALDRIVE0")
 * @param timingCallback - Optional callback for performance event reporting
 * @return DiskpartResult with success status and error message if failed
 */
DiskpartResult unmountVolumes(const QByteArray &device, TimingCallback timingCallback = nullptr);

/**
 * Force Windows to re-read the partition table and re-enumerate volumes on a
 * physical drive. Used to refresh the OS view of a disk after a raw write
 * (whether successful or aborted) so that drive letters get reassigned and
 * Explorer stops showing the disk as missing. Safe to call on a path that
 * isn't a Windows physical drive — it is a no-op in that case.
 *
 * @param device - Windows physical drive path (e.g., "\\\\.\\PHYSICALDRIVE0")
 * @param timingCallback - Optional callback for performance event reporting
 * @return DiskpartResult with success status and error message if failed
 */
DiskpartResult rescanDisk(const QByteArray &device, TimingCallback timingCallback = nullptr);

/**
 * UNRAID: make the first volume on a physical drive reachable through a
 * filesystem path, assigning a free drive letter if Windows did not.
 *
 * Windows normally gives a newly created volume a drive letter on its own, but
 * QA reproduced a machine where it does not (see the comment at the call site in
 * DownloadExtractThread::extractMultiFileRun). Without a letter the volume has
 * no path our extraction code can chdir into, even though it is healthy.
 *
 * If the volume already has an access path this returns that path and reports
 * assignedByUs == false, so callers can distinguish "Windows was just slow" from
 * "Windows never did it".
 *
 * @param device - Windows physical drive path (e.g. "\\\\.\\PHYSICALDRIVE2")
 * @param timingCallback - Optional callback for performance event reporting
 * @return DriveLetterResult with the mount point (e.g. "F:\\") on success
 */
DriveLetterResult assignDriveLetter(const QByteArray &device, TimingCallback timingCallback = nullptr);

} // namespace DiskpartUtil

#endif // DISKPART_UTIL_H 