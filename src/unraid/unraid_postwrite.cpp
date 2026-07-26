/*
 * SPDX-License-Identifier: Apache-2.0
 * Copyright (C) 2026 Lime Technology, Inc.
 */

#include "unraid_postwrite.h"

#include <QDebug>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QProcess>
#include <QRegularExpression>

namespace Unraid {

namespace {

/** Preserve whichever line ending the file already uses (these land on FAT and
 *  are read by both Linux and, when the user edits them, Windows). */
QString detectEol(const QString &text)
{
    return text.contains(QLatin1String("\r\n")) ? QStringLiteral("\r\n") : QStringLiteral("\n");
}

/** Files restored onto the drive when a release zip omits them. Source paths are
 *  Qt resource paths; destinations are relative to the volume root. */
struct PayloadFile {
    const char *resource;
    const char *destination;
};

constexpr PayloadFile kSyslinuxPayload[] = {
    {":/unraid/syslinux/ldlinux.c32",           "syslinux/ldlinux.c32"},
    {":/unraid/syslinux/libcom32.c32",          "syslinux/libcom32.c32"},
    {":/unraid/syslinux/libutil.c32",           "syslinux/libutil.c32"},
    {":/unraid/syslinux/make_bootable_linux.sh","syslinux/make_bootable_linux.sh"},
    {":/unraid/syslinux/make_bootable_mac.sh",  "syslinux/make_bootable_mac.sh"},
    {":/unraid/syslinux/mboot.c32",             "syslinux/mboot.c32"},
    {":/unraid/syslinux/mbr.bin",               "syslinux/mbr.bin"},
    {":/unraid/syslinux/menu.c32",              "syslinux/menu.c32"},
    {":/unraid/syslinux/syslinux",              "syslinux/syslinux"},
    {":/unraid/syslinux/syslinux_linux",        "syslinux/syslinux_linux"},
    {":/unraid/syslinux/syslinux.cfg",          "syslinux/syslinux.cfg"},
    {":/unraid/syslinux/syslinux.cfg-",         "syslinux/syslinux.cfg-"},
    {":/unraid/syslinux/syslinux.exe",          "syslinux/syslinux.exe"},
    {":/unraid/make_bootable_linux",            "make_bootable_linux"},
    {":/unraid/make_bootable_mac",              "make_bootable_mac"},
    {":/unraid/make_bootable.bat",              "make_bootable.bat"},
};

/** True when every network field the wizard needs for a static address is set. */
bool hasCompleteStaticConfig(const QVariantMap &settings)
{
    return settings.contains(QStringLiteral("ipaddr")) &&
           settings.contains(QStringLiteral("netmask")) &&
           settings.contains(QStringLiteral("gateway")) &&
           settings.contains(QStringLiteral("dns"));
}

/** Read, transform, write-back a cfg file. Missing files are not an error: a
 *  release may legitimately not ship one. */
bool patchCfgFile(const QString &path,
                  const std::function<QString(const QString &)> &transform,
                  QString *errorOut)
{
    QFile f(path);
    if (!f.exists()) {
        qDebug() << "Unraid: no" << path << "to patch, skipping";
        return true;
    }

    if (!f.open(QIODevice::ReadOnly)) {
        if (errorOut) {
            *errorOut = QObject::tr("Could not read %1").arg(QFileInfo(path).fileName());
        }
        return false;
    }
    const QString before = QString::fromUtf8(f.readAll());
    f.close();

    const QString after = transform(before);
    if (after == before) {
        return true;
    }

    if (!f.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        if (errorOut) {
            *errorOut = QObject::tr("Could not write %1").arg(QFileInfo(path).fileName());
        }
        return false;
    }
    const qint64 written = f.write(after.toUtf8());
    f.close();

    if (written < 0) {
        if (errorOut) {
            *errorOut = QObject::tr("Could not write %1").arg(QFileInfo(path).fileName());
        }
        return false;
    }
    return true;
}

} // namespace

QString setCfgKey(const QString &contents, const QString &key, const QString &value)
{
    QString text = contents;
    const QString line = QStringLiteral("%1=\"%2\"").arg(key, value);
    const QRegularExpression re(QStringLiteral("^%1=.*$").arg(QRegularExpression::escape(key)),
                                QRegularExpression::MultilineOption);

    if (re.match(text).hasMatch()) {
        text.replace(re, line);
        return text;
    }

    const QString eol = detectEol(text);
    if (!text.isEmpty() && !text.endsWith(QLatin1Char('\n')) && !text.endsWith(QLatin1Char('\r'))) {
        text.append(eol);
    }
    text.append(line + eol);
    return text;
}

QString removeCfgKey(const QString &contents, const QString &key)
{
    QString text = contents;
    const QRegularExpression re(
        QStringLiteral("^%1=.*(?:\\r?\\n)?").arg(QRegularExpression::escape(key)),
        QRegularExpression::MultilineOption);
    text.remove(re);
    return text;
}

bool finalizeFlashDrive(const QString &mountPoint,
                        const QVariantMap &settings,
                        QString *errorOut)
{
    if (mountPoint.isEmpty()) {
        if (errorOut) {
            *errorOut = QObject::tr("Unraid drive was not mounted after extraction");
        }
        return false;
    }

    const QDir root(mountPoint);

    qInfo() << "Unraid: finalising flash drive at" << mountPoint
            << "with" << settings.size() << "customisation setting(s)";

    // 1. Server name -> config/ident.cfg
    //
    // The wizard slot this comes from is upstream's hostname step, so the value
    // arrives under "hostname". "servername" is accepted too because that is the
    // key the pre-2.0 Unraid fork persisted, and settings carried over from an
    // older install would otherwise be silently dropped.
    const QString name = settings.value(QStringLiteral("hostname"),
                                        settings.value(QStringLiteral("servername"))).toString().trimmed();
    if (name.isEmpty()) {
        qInfo() << "Unraid: no server name supplied, leaving config/ident.cfg unchanged";
    } else {
        qInfo() << "Unraid: setting server name to" << name;
        if (!patchCfgFile(root.filePath(QStringLiteral("config/ident.cfg")),
                          [&name](const QString &in) { return setCfgKey(in, QStringLiteral("NAME"), name); },
                          errorOut)) {
            return false;
        }
    }

    // 2. Addressing -> config/network.cfg
    const bool useDhcp = settings.value(QStringLiteral("dhcp"), true).toBool();
    if (useDhcp || hasCompleteStaticConfig(settings)) {
        if (!patchCfgFile(
                root.filePath(QStringLiteral("config/network.cfg")),
                [&settings, useDhcp](const QString &in) {
                    QString out = setCfgKey(in, QStringLiteral("USE_DHCP"),
                                            useDhcp ? QStringLiteral("yes") : QStringLiteral("no"));
                    if (useDhcp) {
                        // Leaving a stale static address behind would override DHCP.
                        out = removeCfgKey(out, QStringLiteral("DNS_SERVER1"));
                    } else {
                        out = setCfgKey(out, QStringLiteral("IPADDR"),
                                        settings.value(QStringLiteral("ipaddr")).toString());
                        out = setCfgKey(out, QStringLiteral("NETMASK"),
                                        settings.value(QStringLiteral("netmask")).toString());
                        out = setCfgKey(out, QStringLiteral("GATEWAY"),
                                        settings.value(QStringLiteral("gateway")).toString());
                        out = setCfgKey(out, QStringLiteral("DNS_SERVER1"),
                                        settings.value(QStringLiteral("dns")).toString());
                    }
                    return out;
                },
                errorOut)) {
            return false;
        }
    }

    // 3. Wi-Fi -> config/wireless.cfg
    //
    // Read by etc/rc.d/rc.wireless (webgui repo). The layout below is not
    // arbitrary — it mirrors a working file taken off a live Unraid 7.3.2
    // server, because rc.wireless makes three structural assumptions:
    //
    //   * WIFI="yes" is a hard gate. Without it rc.wireless logs "Wifi not
    //     enabled" and returns before doing anything else.
    //   * The FIRST section is the interface, not a network. The saved-SSID loop
    //     is `grep '^\[.+\]$' | sed 1d`, so whatever section comes first is
    //     discarded. REGION/REGION_XX live in that section.
    //   * SSID section headers are unquoted. That same loop turns [name] into
    //     "name" itself, so pre-quoting yields ""name"".
    //
    // GROUP="active" is the network rc.wireless joins on boot.
    //
    // PASSWORD is written in plain text on purpose. rc.wireless expects it
    // openssl-encrypted under a key derived from the target's DMI manufacturer
    // and wlan0 MAC — neither of which exists on the machine writing the stick.
    // It handles exactly this case: when decryption yields nothing it treats the
    // value as plaintext and rewrites it encrypted in place on first boot.
    const QString wifiSsid = settings.value(QStringLiteral("wifiSSID")).toString().trimmed();
    if (!wifiSsid.isEmpty()) {
        const QString security = settings.value(QStringLiteral("wifiSecurity"),
                                                QStringLiteral("PSK")).toString();
        const QString password = settings.value(QStringLiteral("wifiPassword")).toString();
        const QString region = settings.value(QStringLiteral("wifiRegion")).toString().trimmed();

        qInfo() << "Unraid: configuring Wi-Fi network" << wifiSsid << "security" << security
                << "region" << region;

        QString cfg;

        // Interface section. Consumed and then skipped by the saved-SSID loop.
        cfg += QStringLiteral("[wlan0]\n");
        cfg += QStringLiteral("WIFI=\"yes\"\n");
        cfg += QStringLiteral("REGION=\"%1\"\n").arg(region);
        // Only consulted when REGION is "00" (the world domain), but rc.wireless
        // reads it unconditionally, so keep the key present.
        cfg += QStringLiteral("REGION_XX=\"\"\n");

        // Network section. Unquoted: the loop adds the quotes.
        cfg += QStringLiteral("[%1]\n").arg(wifiSsid);
        cfg += QStringLiteral("GROUP=\"active\"\n");
        cfg += QStringLiteral("SECURITY=\"%1\"\n").arg(security);
        cfg += QStringLiteral("PASSWORD=\"%1\"\n").arg(password);
        cfg += QStringLiteral("AUTOJOIN=\"yes\"\n");

        // IPv4 follows the same DHCP choice as the wired step, so a
        // static-addressed server does not silently come up on DHCP over Wi-Fi.
        const QString mask = settings.value(QStringLiteral("netmask"),
                                            QStringLiteral("255.255.255.0")).toString();
        cfg += QStringLiteral("DHCP4=\"%1\"\n").arg(useDhcp ? QStringLiteral("yes")
                                                             : QStringLiteral("no"));
        cfg += QStringLiteral("IP4=\"%1\"\n").arg(useDhcp ? QString()
                                                           : settings.value(QStringLiteral("ipaddr")).toString());
        cfg += QStringLiteral("MASK4=\"%1\"\n").arg(mask);
        cfg += QStringLiteral("GATEWAY4=\"%1\"\n").arg(useDhcp ? QString()
                                                                : settings.value(QStringLiteral("gateway")).toString());
        cfg += QStringLiteral("DNS4=\"%1\"\n").arg(useDhcp ? QStringLiteral("no")
                                                            : QStringLiteral("yes"));
        cfg += QStringLiteral("SERVER4=\"%1\"\n").arg(useDhcp ? QString()
                                                               : settings.value(QStringLiteral("dns")).toString());

        // IPv6 defaults, matching a stock configured server. The wizard does not
        // offer IPv6, but the webGUI expects these keys to exist.
        cfg += QStringLiteral("DHCP6=\"yes\"\n");
        cfg += QStringLiteral("IP6=\"\"\n");
        cfg += QStringLiteral("MASK6=\"64\"\n");
        cfg += QStringLiteral("GATEWAY6=\"\"\n");
        cfg += QStringLiteral("DNS6=\"no\"\n");
        cfg += QStringLiteral("SERVER6=\"\"\n");

        const QString wirelessPath = root.filePath(QStringLiteral("config/wireless.cfg"));
        QFile wf(wirelessPath);
        if (!wf.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
            if (errorOut) {
                *errorOut = QObject::tr("Could not write Wi-Fi settings to the drive");
            }
            return false;
        }
        if (wf.write(cfg.toUtf8()) < 0) {
            wf.close();
            if (errorOut) {
                *errorOut = QObject::tr("Could not write Wi-Fi settings to the drive");
            }
            return false;
        }
        wf.close();
    }

    // 4. Restore syslinux + make_bootable helpers when the zip did not carry them.
    //    mkdir() returning false means the directory already exists, i.e. the
    //    release shipped its own copy, which we must not overwrite.
    QDir target(mountPoint);
    if (target.mkdir(QStringLiteral("syslinux"))) {
        for (const auto &file : kSyslinuxPayload) {
            const QString destination = root.filePath(QString::fromLatin1(file.destination));
            if (!QFile::copy(QString::fromLatin1(file.resource), destination)) {
                if (errorOut) {
                    *errorOut = QObject::tr("Could not write boot files to the drive (%1)")
                                    .arg(QString::fromLatin1(file.destination));
                }
                return false;
            }
            // Resource files come out read-only; the helper scripts must be
            // executable for the user to run them afterwards.
            QFile::setPermissions(destination,
                                  QFile::ReadOwner | QFile::WriteOwner | QFile::ExeOwner |
                                      QFile::ReadGroup | QFile::ExeGroup |
                                      QFile::ReadOther | QFile::ExeOther);
        }
    }

#ifdef Q_OS_WIN
    // 4. Install the boot sector. Windows only — see header.
    QProcess proc;
    proc.setWorkingDirectory(mountPoint);
    proc.start(QStringLiteral("cmd.exe"),
               {QStringLiteral("/C"), QStringLiteral("echo Y | make_bootable.bat")});
    if (!proc.waitForFinished(120000) || proc.exitCode() != 0) {
        if (errorOut) {
            *errorOut = QObject::tr("Failed to make the drive bootable (make_bootable.bat)");
        }
        return false;
    }
#endif

    return true;
}

} // namespace Unraid
