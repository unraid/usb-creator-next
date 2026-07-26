/*
 * SPDX-License-Identifier: Apache-2.0
 * Copyright (C) 2026 Lime Technology, Inc.
 */

#include "unraid_guid.h"

#include "config.h"
#include "drivelist/drivelist.h"

#include <QDebug>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QPointer>
#include <QUrlQuery>

namespace Unraid {

QString normaliseGuidField(const QString &value, int width)
{
    if (width <= 0) {
        return {};
    }

    // Strip whitespace anywhere in the field, then upper-case. unraidd counts
    // only non-blank characters when deciding whether to pad or truncate.
    QString compact;
    compact.reserve(value.size());
    for (const QChar &c : value) {
        if (!c.isSpace()) {
            compact.append(c.toUpper());
        }
    }

    if (compact.size() == width) {
        return compact;
    }
    if (compact.size() < width) {
        // Left-pad with '0'.
        return compact.rightJustified(width, QLatin1Char('0'));
    }
    // Longer than the field: unraidd discards from the *beginning*, keeping the
    // trailing `width` characters.
    return compact.right(width);
}

QString deviceGuid(const Drivelist::DeviceDescriptor &device)
{
    if (!device.isUSB) {
        return {};
    }

    const QString rawVid = QString::fromStdString(device.vid);
    const QString rawPid = QString::fromStdString(device.pid);
    const QString rawSerial = QString::fromStdString(device.serialNumber);

    // No identity at all: not a GUID-bearing device, say nothing.
    if (rawVid.trimmed().isEmpty() && rawPid.trimmed().isEmpty() && rawSerial.trimmed().isEmpty()) {
        return {};
    }

    const QString vid = normaliseGuidField(rawVid, 4);
    const QString pid = normaliseGuidField(rawPid, 4);
    const QString serial = normaliseGuidField(rawSerial, 16);

    // unraidd formats as "%.4s-%.4s-%.4s-%.12s" over the 4/4/16 buffers, i.e. the
    // 16-char serial is split 4 then 12.
    return QStringLiteral("%1-%2-%3-%4")
        .arg(vid, pid, serial.left(4), serial.mid(4));
}

GuidValidator::GuidValidator(QObject *parent)
    : QObject(parent)
{
}

GuidValidator::Status GuidValidator::cachedStatus(const QString &guid) const
{
    return _cache.value(guid, Status::Unknown);
}

void GuidValidator::requestValidation(const QString &guid)
{
    if (guid.isEmpty() || _cache.contains(guid) || _inFlight.value(guid, false)) {
        return;
    }
    _inFlight.insert(guid, true);

    // One manager per validator, owned by it; replies are deleted on finish.
    static thread_local QNetworkAccessManager *manager = nullptr;
    if (!manager) {
        manager = new QNetworkAccessManager();
    }

    QNetworkRequest request{QUrl(QStringLiteral(UNRAID_GUID_URL))};
    request.setHeader(QNetworkRequest::ContentTypeHeader,
                      QStringLiteral("application/x-www-form-urlencoded"));
    request.setAttribute(QNetworkRequest::RedirectPolicyAttribute,
                         QNetworkRequest::NoLessSafeRedirectPolicy);

    QUrlQuery form;
    form.addQueryItem(QStringLiteral("guid"), guid);

    QNetworkReply *reply = manager->post(request, form.toString(QUrl::FullyEncoded).toUtf8());
    QPointer<GuidValidator> self(this);

    connect(reply, &QNetworkReply::finished, reply, [self, reply, guid]() {
        reply->deleteLater();
        if (!self) {
            return;
        }

        const int httpStatus =
            reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();

        Status status;
        if (reply->error() != QNetworkReply::NoError && httpStatus == 0) {
            // Transport failure (offline, DNS, TLS). We cannot tell whether the
            // GUID is good, so do NOT cache a verdict — leave it Unknown so the UI
            // stays neutral and a later poll can retry.
            qDebug() << "Unraid GUID validation unavailable for" << guid << ":"
                     << reply->errorString();
            self->_inFlight.remove(guid);
            emit self->guidValidated(guid, Status::Unknown);
            return;
        }

        // The key server answers 403 for a blacklisted / non-unique GUID.
        status = (httpStatus == 403) ? Status::Blacklisted : Status::Valid;

        self->_cache.insert(guid, status);
        self->_inFlight.remove(guid);
        emit self->guidValidated(guid, status);
    });
}

} // namespace Unraid
