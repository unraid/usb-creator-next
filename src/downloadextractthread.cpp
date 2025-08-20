/*
 * SPDX-License-Identifier: Apache-2.0
 * Copyright (C) 2020 Raspberry Pi Ltd
 */

#include "downloadextractthread.h"
#include "config.h"
#include "dependencies/drivelist/src/drivelist.hpp"
#include "dependencies/mountutils/src/mountutils.hpp"
#include <iostream>
#include <archive.h>
#include <archive_entry.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <string.h>
#include <stdlib.h>
#include <fcntl.h>
#include <QDir>
#include <QProcess>
#include <QTemporaryDir>
#include <QDebug>
#include <QDomDocument>

using namespace std;

const int DownloadExtractThread::MAX_QUEUE_SIZE = 64;

class _extractThreadClass : public QThread {
public:
    _extractThreadClass(DownloadExtractThread *parent)
        : QThread(parent), _de(parent)
    {
    }

    virtual void run()
    {
        if (_de->isImage())
            _de->extractImageRun();
        else
            _de->extractMultiFileRun();
    }

protected:
    DownloadExtractThread *_de;
};

DownloadExtractThread::DownloadExtractThread(const QByteArray &url, const QByteArray &localfilename, const QByteArray &expectedHash, QObject *parent)
    : DownloadThread(url, localfilename, expectedHash, parent), _abufsize(IMAGEWRITER_BLOCKSIZE), _ethreadStarted(false),
      _isImage(true), _inputHash(OSLIST_HASH_ALGORITHM), _activeBuf(0), _writeThreadStarted(false)
{
    _extractThread = new _extractThreadClass(this);
    _abuf[0] = (char *) qMallocAligned(_abufsize, 4096);
    _abuf[1] = (char *) qMallocAligned(_abufsize, 4096);
}

DownloadExtractThread::~DownloadExtractThread()
{
    _cancelled = true;
    _cancelExtract();
    if (!_extractThread->wait(10000))
    {
        _extractThread->terminate();
    }
    qFreeAligned(_abuf[0]);
    qFreeAligned(_abuf[1]);
}

size_t DownloadExtractThread::_writeData(const char *buf, size_t len)
{
    if (_cancelled)
        return 0;

    _writeCache(buf, len);

    if (!_ethreadStarted)
    {
        // Extract thread is started when first data comes in
        _ethreadStarted = true;
        _extractThread->start();
        msleep(100);
    }

    if (!_isImage)
    {
        _inputHash.addData(buf, len);
    }

    _pushQueue(buf, len);

    return len;
}

void DownloadExtractThread::_onDownloadSuccess()
{
    _pushQueue("", 0);
}

void DownloadExtractThread::_onDownloadError(const QString &msg)
{
    DownloadThread::_onDownloadError(msg);
    _cancelExtract();
}

void DownloadExtractThread::_cancelExtract()
{
    std::unique_lock<std::mutex> lock(_queueMutex);
    _queue.clear();
    _queue.push_back(QByteArray());
    lock.unlock();
    _cv.notify_all();
}

void DownloadExtractThread::cancelDownload()
{
    DownloadThread::cancelDownload();
    _cancelExtract();
}

// Raise exception on libarchive errors
static inline void _checkResult(int r, struct archive *a)
{
    if (r < ARCHIVE_OK)
        // Warning
        qDebug() << archive_error_string(a);
    if (r < ARCHIVE_WARN)
        // Fatal
        throw runtime_error(archive_error_string(a));
}

// libarchive thread
void DownloadExtractThread::extractImageRun()
{
    struct archive *a = archive_read_new();
    struct archive_entry *entry;
    int r;

    archive_read_support_filter_all(a);
    archive_read_support_format_zip(a);
    archive_read_support_format_7zip(a);
    archive_read_support_format_raw(a); // for .gz and such
    archive_read_open(a, this, NULL, &DownloadExtractThread::_archive_read, &DownloadExtractThread::_archive_close);

    try
    {
        r = archive_read_next_header(a, &entry);
        _checkResult(r, a);

        while (true)
        {
            ssize_t size = archive_read_data(a, _abuf[_activeBuf], _abufsize);
            if (size < 0)
                throw runtime_error(archive_error_string(a));
            if (size == 0)
                break;
            if (size % 512 != 0)
            {
                size_t paddingBytes = 512-(size % 512);
                qDebug() << "Image is NOT a valid disk image, as its length is not a multiple of the sector size of 512 bytes long";
                qDebug() << "Last write() would be" << size << "bytes, but padding to" << size + paddingBytes << "bytes";
                memset(_abuf[_activeBuf]+size, 0, paddingBytes);
                size += paddingBytes;
            }

            if (_writeThreadStarted)
            {
                //if (_writeFile(_abuf, size) != (size_t) size)
                if (!_writeFuture.result())
                {
                    if (!_cancelled)
                    {
                        _onWriteError();
                    }
                    archive_read_free(a);
                    return;
                }
            }

#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
            _writeFuture = QtConcurrent::run(&DownloadThread::_writeFile, static_cast<DownloadThread *>(this), _abuf[_activeBuf], size);
#else
            _writeFuture = QtConcurrent::run(static_cast<DownloadThread *>(this), &DownloadThread::_writeFile, _abuf[_activeBuf], size);
#endif
            _activeBuf = _activeBuf ? 0 : 1;
            _writeThreadStarted = true;
        }

        if (_writeThreadStarted)
            _writeFuture.waitForFinished();
        _writeComplete();
    }
    catch (exception &e)
    {
        if (!_cancelled)
        {
            // Fatal error
            DownloadThread::cancelDownload();
            emit error(tr("Error extracting archive: %1").arg(e.what()));
        }
    }

    archive_read_free(a);
}

#ifdef Q_OS_LINUX
/* Returns true if folder lives on a different device than parent directory */
inline bool isMountPoint(const QString &folder)
{
    struct stat statFolder, statParent;
    QFileInfo fi(folder);
    QByteArray folderAscii = folder.toLatin1();
    QByteArray parentDir   = fi.dir().path().toLatin1();

    if ( ::stat(folderAscii.constData(), &statFolder) == -1
         || ::stat(parentDir.constData(), &statParent) == -1)
    {
        return false;
    }

    return (statFolder.st_dev != statParent.st_dev);
}
#endif

void DownloadExtractThread::extractMultiFileRun()
{
    QString folder;
    QStringList filesExtracted, dirExtracted;
    QByteArray devlower = _filename.toLower();

    /* See if OS auto-mounted the device */
    for (int tries = 0; tries < 3; tries++)
    {
        QThread::sleep(1);
        auto l = Drivelist::ListStorageDevices();
        for (const auto& i : l)
        {
            if (QByteArray::fromStdString(i.device).toLower() == devlower && i.mountpoints.size() == 1)
            {
                folder = QByteArray::fromStdString(i.mountpoints.front());
                break;
            }
        }
    }

#ifdef Q_OS_LINUX
    bool manualmount = false;

    if (folder.isEmpty())
    {
        /* Manually mount folder */
        QTemporaryDir td;
        QStringList args;
        folder = td.path();
        QByteArray fatpartition = _filename;
        if (isdigit(fatpartition.at(fatpartition.length()-1)))
            fatpartition += "p1";
        else
            fatpartition += "1";
        args << "-t" << "vfat" << fatpartition << folder;

        if (QProcess::execute("mount", args) != 0)
        {
            emit error(tr("Error mounting FAT32 partition"));
            return;
        }
        td.setAutoRemove(false);
        manualmount = true;
    }

    /* When run under some container environments -even when udisks2 said
       it completed mounting the fs- we may have to wait a bit more
       until mountpoint is available in sandbox which lags behind */
    for (int tries=0; tries<3; tries++)
    {
        if (isMountPoint(folder))
            break;
        QThread::sleep(1);
    }
#endif

    if (folder.isEmpty())
    {
        emit error(tr("Operating system did not mount FAT32 partition"));
        return;
    }

    QString currentDir;
    struct archive *a = archive_read_new();
    struct archive *ext = archive_write_disk_new();
    struct archive_entry *entry;
    /* Extra safety checks: do not allow existing files to be overwritten (SD card should be formatted by previous step),
     * do not allow absolute paths, do not allow insecure symlinks, no special permissions */
    int r, flags = ARCHIVE_EXTRACT_TIME | ARCHIVE_EXTRACT_SECURE_NOABSOLUTEPATHS
            | ARCHIVE_EXTRACT_SECURE_NODOTDOT | ARCHIVE_EXTRACT_SECURE_SYMLINKS | ARCHIVE_EXTRACT_NO_OVERWRITE
            /*ARCHIVE_EXTRACT_PERM | ARCHIVE_EXTRACT_ACL | ARCHIVE_EXTRACT_FFLAGS | ARCHIVE_EXTRACT_XATTR*/;
#ifndef Q_OS_WIN
    if (::getuid() == 0)
        flags |= ARCHIVE_EXTRACT_OWNER;
#endif

    currentDir = QDir::currentPath();

    if (!QDir::setCurrent(folder))
    {
        DownloadThread::cancelDownload();
        emit error(tr("Error changing to directory '%1'").arg(folder));
        return;
    }

    archive_read_support_filter_all(a);
    archive_read_support_format_all(a);
    archive_write_disk_set_options(ext, flags);
    archive_read_open(a, this, NULL, &DownloadExtractThread::_archive_read, &DownloadExtractThread::_archive_close);

    try
    {
        while ( (r = archive_read_next_header(a, &entry)) != ARCHIVE_EOF)
        {
          _checkResult(r, a);
          r = archive_write_header(ext, entry);
          if (r < ARCHIVE_OK)
              qDebug() << archive_error_string(ext);
          else if (archive_entry_size(entry) > 0)
          {
              //checkResult(copyData(a, ext), a);
              const void *buff;
              size_t size;
              int64_t offset;
              QString filename = QString::fromWCharArray(archive_entry_pathname_w(entry));

              if (archive_entry_filetype(entry) == AE_IFDIR) // Empty directory
                  dirExtracted.append(filename);
              else
                  filesExtracted.append(filename);

              while ( (r = archive_read_data_block(a, &buff, &size, &offset)) != ARCHIVE_EOF)
              {
                  _checkResult(r, a);
                  _checkResult(archive_write_data_block(ext, buff, size, offset), ext);
                  _bytesWritten += size;
              }
          }
          _checkResult(archive_write_finish_entry(ext), ext);
        }

        QByteArray computedHash = _inputHash.result().toHex();
        qDebug() << "Hash of compressed multi-file zip:" << computedHash;
        if (!_expectedHash.isEmpty() && _expectedHash != computedHash)
        {
            qDebug() << "Mismatch with expected hash:" << _expectedHash;
            throw runtime_error("Download corrupt. SHA256 does not match");
        }
        if (_cacheEnabled && _expectedHash == computedHash)
        {
            _cachefile.close();
            emit cacheFileUpdated(computedHash);
        }

        if(_initFormat == "UNRAID") {
            _writeUnraidNetworkSettings();
            _writeUnraidServerSettings();
            _writeUnraidLanguageSettings();
            _writeUnraidSyslinuxFiles();
            _runUnraidMakeBootableScript();
        }
        emit success();
    }
    catch (exception &e)
    {
        if (_cachefile.isOpen())
            _cachefile.remove();

        qDebug() << "Deleting extracted files";
        for (const auto& filename : filesExtracted)
        {
            QFileInfo fi(filename);
            QString path = fi.path();
            if (!path.isEmpty() && path != "." && !dirExtracted.contains(path))
                dirExtracted.append(path);

            QFile::remove(filename);
        }
        for (int idx = dirExtracted.count()-1; idx >= 0; idx--)
        {
            QDir d;
            d.rmdir(dirExtracted[idx]);
        }
        qDebug() << filesExtracted << dirExtracted;

        if (!_cancelled)
        {
            /* Fatal error */
            DownloadThread::cancelDownload();
            emit error(tr("Error extracting archive: %1").arg(e.what()));
        }
    }

    archive_read_free(a);
    archive_write_free(ext);
    QDir::setCurrent(currentDir);

#ifdef Q_OS_LINUX
    if (manualmount)
    {
        QStringList args;
        args << folder;
        QProcess::execute("umount", args);
        QDir d;
        d.rmdir(folder);
    }
#endif

    //eject_disk(_filename.constData());
}

ssize_t DownloadExtractThread::_on_read(struct archive *, const void **buff)
{
    _buf = _popQueue();
    *buff = _buf.data();
    return _buf.size();
}

int DownloadExtractThread::_on_close(struct archive *)
{
    return 0;
}

// static callback functions that call object oriented equivalents
ssize_t DownloadExtractThread::_archive_read(struct archive *a, void *client_data, const void **buff)
{
   return qobject_cast<DownloadExtractThread *>((QObject *) client_data)->_on_read(a, buff);
}

int DownloadExtractThread::_archive_close(struct archive *a, void *client_data)
{
   return qobject_cast<DownloadExtractThread *>((QObject *) client_data)->_on_close(a);
}

bool DownloadExtractThread::isImage()
{
    return _isImage;
}

void DownloadExtractThread::enableMultipleFileExtraction()
{
    _isImage = false;
}

// Synchronized queue using monitor consumer/producer pattern
QByteArray DownloadExtractThread::_popQueue()
{
    std::unique_lock<std::mutex> lock(_queueMutex);

    _cv.wait(lock, [this]{
            return _queue.size() != 0;
    });

    QByteArray result = _queue.front();
    _queue.pop_front();

    if (_queue.size() == (MAX_QUEUE_SIZE-1))
    {
        lock.unlock();
        _cv.notify_one();
    }

    return result;
}

void DownloadExtractThread::_pushQueue(const char *data, size_t len)
{
    std::unique_lock<std::mutex> lock(_queueMutex);

    _cv.wait(lock, [this]{
            return _queue.size() != MAX_QUEUE_SIZE;
    });

    _queue.emplace_back(data, len);

    if (_queue.size() == 1)
    {
        lock.unlock();
        _cv.notify_one();
    }
}

void DownloadExtractThread::_writeUnraidNetworkSettings(const QString& dstDir)
{
    if(_allNetworkSettingsPresent() && _imgWriterSettings["static"].toBool())
    {
        QFile fileNetwork(dstDir + "/config/network.cfg");
        if (fileNetwork.exists())
        {
            fileNetwork.open(QIODevice::ReadOnly);
            QString dataText = fileNetwork.readAll();
            fileNetwork.close();

            dataText.replace("USE_DHCP=\"yes\"", "USE_DHCP=\"no\"");
            dataText.replace("IPADDR=", "IPADDR=\"" + _imgWriterSettings["ipaddr"].toString() + "\"");
            dataText.replace("NETMASK=", "NETMASK=\"" + _imgWriterSettings["netmask"].toString() + "\"");
            dataText.replace("GATEWAY=", "GATEWAY=\"" + _imgWriterSettings["gateway"].toString() + "\"");
            dataText.append("DNS_SERVER1=\"" + _imgWriterSettings["dns"].toString() + "\"\r\n");

            if (fileNetwork.open(QFile::WriteOnly | QFile::Truncate))
            {
                QTextStream out(&fileNetwork);
                out << dataText;
            }
            fileNetwork.close();
        }

    }
}

void DownloadExtractThread::_writeUnraidServerSettings(const QString& dstDir)
{
    if(_imgWriterSettings.contains("servername")) {
        QFile fileIdent(dstDir + "/config/ident.cfg");
        if (fileIdent.exists())
        {
            fileIdent.open(QIODevice::ReadOnly);
            QString dataText = fileIdent.readAll();
            fileIdent.close();

            dataText.replace("NAME=\"Tower\"", "NAME=\"" + _imgWriterSettings["servername"].toString() + "\"");

            if (fileIdent.open(QFile::WriteOnly | QFile::Truncate))
            {
                QTextStream out(&fileIdent);
                out << dataText;
            }
            fileIdent.close();
        }
    }
}

void DownloadExtractThread::_writeUnraidLanguageSettings(const QString& dstDir)
{
    if(_imgWriterSettings.contains("UNRAID_LANG_JSON")) {
        // remove this tmp file now that we're definitely done with it
        QFile langJson(_imgWriterSettings["UNRAID_LANG_JSON"].toByteArray());
        langJson.remove();
    }

    if(_imgWriterSettings.contains("UNRAID_LANG_CODE"))
    {
        QString unraidLangCode(_imgWriterSettings["UNRAID_LANG_CODE"].toString());
        if(_imgWriterSettings.contains("UNRAID_LANG_XML")) {
            QFile langXml(_imgWriterSettings["UNRAID_LANG_XML"].toByteArray());
            QFile::rename(langXml.fileName(), dstDir + "/config/plugins/lang-" + unraidLangCode + ".xml");
        }

        if(_imgWriterSettings.contains("UNRAID_LANG_ZIP")) {
            QFile langZip(_imgWriterSettings["UNRAID_LANG_ZIP"].toByteArray());
            QFile::rename(langZip.fileName(), dstDir + "/config/plugins/dynamix/lang-" + unraidLangCode + ".zip");
        }
        QFile dynamixCfg(dstDir + "/config/plugins/dynamix/dynamix.cfg");
        if (dynamixCfg.exists())
        {
            dynamixCfg.open(QIODevice::ReadOnly);
            QString dataText = dynamixCfg.readAll();
            dynamixCfg.close();

            _addLocaleToUnraidDynamixConfig(dataText, unraidLangCode);

            if (dynamixCfg.open(QFile::WriteOnly | QFile::Truncate))
            {
                QTextStream out(&dynamixCfg);
                out << dataText;
            }
            dynamixCfg.close();
        }
    }
}

void DownloadExtractThread::_writeUnraidSyslinuxFiles(const QString& dstDir)
{
    // restore make bootable scripts and/or syslinux, if necessary
    QDir dirTarget(dstDir);
    if (dirTarget.mkdir("syslinux"))
    {
        QFile::copy(":/unraid/syslinux/ldlinux.c32", dstDir + "/syslinux/ldlinux.c32");
        QFile::copy(":/unraid/syslinux/libcom32.c32", dstDir + "/syslinux/libcom32.c32");
        QFile::copy(":/unraid/syslinux/libutil.c32", dstDir + "/syslinux/libutil.c32");
        QFile::copy(":/unraid/syslinux/make_bootable_linux.sh", dstDir + "/syslinux/make_bootable_linux.sh");
        QFile::copy(":/unraid/syslinux/make_bootable_mac.sh", dstDir + "/syslinux/make_bootable_mac.sh");
        QFile::copy(":/unraid/syslinux/mboot.c32", dstDir + "/syslinux/mboot.c32");
        QFile::copy(":/unraid/syslinux/mbr.bin", dstDir + "/syslinux/mbr.bin");
        QFile::copy(":/unraid/syslinux/menu.c32", dstDir + "/syslinux/menu.c32");
        QFile::copy(":/unraid/syslinux/syslinux", dstDir + "/syslinux/syslinux");
        QFile::copy(":/unraid/syslinux/syslinux_linux", dstDir + "/syslinux/syslinux_linux");
        QFile::copy(":/unraid/syslinux/syslinux.cfg", dstDir + "/syslinux/syslinux.cfg");
        QFile::copy(":/unraid/syslinux/syslinux.cfg-", dstDir + "/syslinux/syslinux.cfg-");
        QFile::copy(":/unraid/syslinux/syslinux.exe", dstDir + "/syslinux/syslinux.exe");
        QFile::copy(":/unraid/make_bootable_linux", dstDir + "/make_bootable_linux");
        QFile::copy(":/unraid/make_bootable_mac", dstDir + "/make_bootable_mac");
        QFile::copy(":/unraid/make_bootable.bat", dstDir + "/make_bootable.bat");
    }
}

void DownloadExtractThread::_runUnraidMakeBootableScript()
{
#ifdef Q_OS_WIN
    QString program{"cmd.exe"};
    QStringList args;
    args << "/C" << "echo Y | make_bootable.bat";

    int retcode = QProcess::execute(program, args);

    if (retcode)
    {
        throw runtime_error("Error running make_bootable script");
    }
#endif
}

void DownloadExtractThread::_addLocaleToUnraidDynamixConfig(QString& dataText, const QString& unraidLangCode) 
{
    QDomDocument doc;
    QString errorMsg;
    int errorLine, errorColumn;

    // Load the dataText as an XML document
    if (!doc.setContent(dataText, &errorMsg, &errorLine, &errorColumn)) 
    {
        throw runtime_error("Error parsing XML at line" + errorLine + "column" + errorColumn + ":" + errorMsg);
    }

    // Find the <display> section
    QDomElement root = doc.documentElement(); // Get the root element
    QDomNodeList displaySections = root.elementsByTagName("display");

    if (!displaySections.isEmpty()) 
    {
        QDomElement display = displaySections.at(0).toElement(); // Assuming only one <display> section

        if (!display.isNull()) 
        {
            // Check if "locale" attribute exists
            if (display.hasAttribute("locale")) 
            {
                display.setAttribute("locale", unraidLangCode);
            } 
            else 
            {
                // Add "locale" attribute if not present
                display.setAttribute("locale", unraidLangCode);
            }
        }
    } 
    else 
    {
        // Add a new [display] section with the locale attribute
        QDomElement newDisplay = doc.createElement("display");
        newDisplay.setAttribute("locale", unraidLangCode);
        root.appendChild(newDisplay);
    }

    // Convert the modified XML back to a string
    QString newXml;
    QTextStream stream(&newXml);
    doc.save(stream, 4); // Indent with 4 spaces
    dataText = newXml;
}
