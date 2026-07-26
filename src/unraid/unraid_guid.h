/*
 * SPDX-License-Identifier: Apache-2.0
 * Copyright (C) 2026 Lime Technology, Inc.
 *
 * Unraid flash-device GUID derivation and validation.
 */

#ifndef UNRAID_GUID_H
#define UNRAID_GUID_H

#include <string>

#include <QObject>
#include <QHash>
#include <QString>

namespace Drivelist {
struct DeviceDescriptor;
}

namespace Unraid {

/**
 * @brief Normalise one GUID field exactly as unraidd does.
 *
 * This mirrors `strncpy_guid()` in unraidd's regis.c. The rules there are:
 *
 *   - discard all whitespace
 *   - upper-case everything
 *   - if shorter than `width`, left-pad with '0'
 *   - if longer than `width`, discard characters from the *beginning*
 *
 * so the result is always exactly `width` characters.
 *
 * Getting this wrong is not cosmetic: the GUID computed here is what the licence
 * is issued against, and unraidd recomputes it at boot from the same USB
 * descriptor fields. Any divergence produces a key that will not validate on the
 * machine it was bought for.
 */
QString normaliseGuidField(const QString &value, int width);

/**
 * @brief Build the 27-character Unraid flash GUID for a device.
 *
 * Layout is `VVVV-PPPP-SSSS-SSSSSSSSSSSS`: vendor id (4), product id (4), then
 * the 16-character serial split 4/12. unraidd reads the same three values via
 * `udevadm test-builtin usb_id` (ID_VENDOR_ID / ID_MODEL_ID / ID_SERIAL_SHORT).
 *
 * Returns an empty string when the device is not USB or reports no identity at
 * all. A device with a blank serial still yields a GUID — with an all-zero serial
 * field — which is deliberate: unraidd blacklists exactly that shape, so we want
 * it surfaced to the user rather than silently hidden.
 */
QString deviceGuid(const Drivelist::DeviceDescriptor &device);

/**
 * @brief Asynchronous, cached validator for flash GUIDs.
 *
 * Validation is a network round-trip to the Unraid key server. The drive list is
 * re-polled continuously, so this must never happen inline: the previous
 * implementation ran a blocking libcurl POST per device inside
 * DriveListModel::processDriveList, which executes on the UI thread, freezing the
 * window on every poll for as long as the key server took to answer.
 *
 * Instead, callers ask for a cached verdict (which never blocks) and connect to
 * guidValidated() for the answer. Each distinct GUID is only ever checked once
 * per session.
 */
class GuidValidator : public QObject
{
    Q_OBJECT
public:
    explicit GuidValidator(QObject *parent = nullptr);

    enum class Status {
        Unknown,   ///< not checked yet (or check in flight)
        Valid,     ///< key server accepted the GUID
        Blacklisted ///< key server rejected the GUID (HTTP 403)
    };

    /** Cached verdict for @p guid. Never blocks; never issues a request. */
    Status cachedStatus(const QString &guid) const;

    /** Queue a check for @p guid if one has not already run or is not in flight. */
    void requestValidation(const QString &guid);

signals:
    void guidValidated(const QString &guid, Unraid::GuidValidator::Status status);

private:
    QHash<QString, Status> _cache;
    QHash<QString, bool> _inFlight;
};

} // namespace Unraid

#endif // UNRAID_GUID_H
