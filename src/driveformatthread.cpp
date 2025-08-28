/*
 * SPDX-License-Identifier: Apache-2.0
 * Copyright (C) 2020 Raspberry Pi Ltd
 */

#include "driveformatthread.h"
#include "dependencies/drivelist/src/drivelist.hpp"
#include "dependencies/mountutils/src/mountutils.hpp"
#include "disk_formatter.h"
#include <QCoreApplication>
#include <QDebug>
#include <QProcess>
#include <QTemporaryFile>
#include <regex>

#ifdef Q_OS_LINUX
#include "linux/udisks2api.h"
#include <unistd.h>
#endif

#ifdef Q_OS_WIN
#include "windows/volume_locks.h"
#endif

DriveFormatThread::DriveFormatThread(const QByteArray &device,
                                     const QString &label, QObject *parent)
    : QThread(parent), _device(device), _label(label) {}

DriveFormatThread::~DriveFormatThread() { wait(); }

std::uint64_t DriveFormatThread::getDeviceSize(const QByteArray &device) {
  auto driveList = Drivelist::ListStorageDevices();
  for (const auto &drive : driveList) {
    if (QByteArray::fromStdString(drive.device) == device) {
      return drive.size;
    }
  }

  qDebug() << "Warning: Could not find device size for" << device
           << ", using default";
  return 64ULL * 1024 * 1024 * 1024; // Default to 64GB if not found
}

void DriveFormatThread::run() {
#ifdef Q_OS_WIN

#ifdef HAVE_FAT32FORMAT_FALLBACK
  qDebug() << "Formatting Windows device" << _device
           << "with diskpart + fat32format";

  std::regex windriveregex("\\\\\\\\.\\\\PHYSICALDRIVE([0-9]+)",
                           std::regex_constants::icase);
  std::cmatch m;

  if (std::regex_match(_device.constData(), m, windriveregex)) {
    QByteArray nr = QByteArray::fromStdString(m[1]);

    qDebug() << "Formatting Windows drive #" << nr << "(" << _device << ")";

    QProcess proc;
    proc.setProcessChannelMode(QProcess::ForwardedChannels);
    QByteArray diskpartCmds = "select disk " + nr +
                              "\r\n"
                              "clean\r\n"
                              "create partition primary\r\n"
                              "select partition 1\r\n"
                              "set id=0e\r\n"
                              "assign\r\n"
                              "exit\r\n";
    proc.start("diskpart", QStringList());
    proc.waitForStarted();
    proc.write(diskpartCmds);
    proc.closeWriteChannel();
    bool finished = proc.waitForFinished(-1);
    qDebug() << "Diskpart finished: " << finished;

    QByteArray output = proc.readAllStandardError();
    qDebug() << output;
    qDebug() << "Done running diskpart. Exit status code =" << proc.exitCode();

    if (proc.exitCode()) {
      emit error(tr("Error partitioning: %1").arg(QString(output)));
      return;
    }

    auto l = Drivelist::ListStorageDevices();
    QByteArray devlower = _device.toLower();
    for (auto i : l) {
      if (QByteArray::fromStdString(i.device).toLower() == devlower &&
          i.mountpoints.size() == 1) {
        QByteArray driveLetter =
            QByteArray::fromStdString(i.mountpoints.front());
        if (driveLetter.endsWith("\\"))
          driveLetter.chop(1);
        qDebug() << "Drive letter of device:" << driveLetter;



        const auto lockers = whoIsUsingPath(QString::fromLatin1(driveLetter) + "\\");
        qDebug().noquote() << "Potential lockers:" << lockers.join(", ");


        QProcess f32format;
        QStringList args;

        if (!_label.isEmpty()) {
          args << "-l" + _label;
        }

        args << "-y" << driveLetter;

        f32format.setProcessChannelMode(QProcess::ForwardedChannels);

        f32format.start(
            QCoreApplication::applicationDirPath() + "/fat32format.exe", args);
        if (!f32format.waitForStarted()) {
          emit error(tr("Error starting fat32format"));
          return;
        }

        f32format.closeWriteChannel();
        f32format.waitForFinished(120000);

        if (f32format.exitStatus() || f32format.exitCode()) {
          emit error(tr("Error running fat32format: %1")
                         .arg(QString(f32format.readAll())));
        } else {
          emit success();
        }
        return;
      }
    }

    emit error(tr("Error determining new drive letter"));
    return;
  } else {
    emit error(tr("Invalid device: %1").arg(QString(_device)));
    return;
  }
#else
  qDebug() << "Formatting Windows device" << _device
           << "with cross-platform implementation";

  rpi_imager::DiskFormatter formatter;
  auto result =
      formatter.FormatDrive(_device.toStdString(), _label.toStdString());

  if (!result) {
    QString errorMessage;
    switch (result.error()) {
    case rpi_imager::FormatError::kFileOpenError:
      errorMessage = tr("Error opening device for formatting");
      break;
    case rpi_imager::FormatError::kFileWriteError:
      errorMessage = tr("Error writing to device during formatting");
      break;
    case rpi_imager::FormatError::kFileSeekError:
      errorMessage = tr("Error seeking on device during formatting");
      break;
    case rpi_imager::FormatError::kInvalidParameters:
      errorMessage = tr("Invalid parameters for formatting");
      break;
    case rpi_imager::FormatError::kInsufficientSpace:
      errorMessage = tr("Insufficient space on device");
      break;
    default:
      errorMessage = tr("Unknown formatting error");
      break;
    }

    qDebug() << "Cross-platform formatting failed:" << errorMessage;
    emit error(errorMessage);
    return;
  }

  qDebug() << "Cross-platform disk formatter succeeded";
  emit success();
#endif
#elif defined(Q_OS_DARWIN)
  QProcess proc;
  QStringList args;
  QString volName = _label.isEmpty() ? "BOOT" : _label;

  args << "eraseDisk" << "FAT32" << volName << "MBRFormat" << _device;

  proc.start("diskutil", args);
  proc.waitForFinished();

  QByteArray output = proc.readAllStandardError();
  qDebug() << args;
  qDebug() << "diskutil output:" << output;

  if (proc.exitCode()) {
    emit error(tr("Error partitioning: %1").arg(QString(output)));
  } else {
    emit success();
  }

#elif defined(Q_OS_LINUX)

  if (::access(_device.constData(), W_OK) != 0) {
    /* Not running as root, try to outsource formatting to udisks2 */
    if (_label.isEmpty()) {
#ifndef QT_NO_DBUS
      UDisks2Api udisks2;
      if (udisks2.formatDrive(_device)) {
        emit success();
      } else {
#endif
        emit error(tr("Error formatting (through udisks2)"));
#ifndef QT_NO_DBUS
      }
#endif
    } else {
      emit error(tr("Elevated privileges needed to properly format drive."));
    }
    return;
  }

  // Unmount the device before formatting
  unmount_disk(_device);

  qDebug() << "Formatting device" << _device
           << "with clean-room implementation";

  // Get device size
  std::uint64_t deviceSize = getDeviceSize(_device);
  qDebug() << "Device size:" << deviceSize << "bytes";

  // Use our clean-room disk formatter
  rpi_imager::DiskFormatter formatter;
  auto result =
      formatter.FormatDrive(_device.toStdString(), _label.toStdString());

  if (!result) {
    QString errorMessage;
    switch (result.error()) {
    case rpi_imager::FormatError::kFileOpenError:
      errorMessage = tr("Error opening device for formatting");
      break;
    case rpi_imager::FormatError::kFileWriteError:
      errorMessage = tr("Error writing to device during formatting");
      break;
    case rpi_imager::FormatError::kFileSeekError:
      errorMessage = tr("Error seeking on device during formatting");
      break;
    case rpi_imager::FormatError::kInvalidParameters:
      errorMessage = tr("Invalid parameters for formatting");
      break;
    case rpi_imager::FormatError::kInsufficientSpace:
      errorMessage = tr("Insufficient space on device");
      break;
    default:
      errorMessage = tr("Unknown formatting error");
      break;
    }

    qDebug() << "Formatting failed:" << errorMessage;
    emit error(errorMessage);
    return;
  }

  qDebug() << "Formatting completed successfully";
  emit success();

#else
  emit error(tr("Formatting not implemented for this platform"));
#endif
}
