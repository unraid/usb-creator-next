/* SPDX-License-Identifier: Apache-2.0 */
#include "unraid/flash_archive.h"
#include "unraid/unraid_postwrite.h"
#include "disk_formatter.h"

#include <catch2/catch_test_macros.hpp>
#include <QFile>
#include <QTemporaryDir>
#include <QtEndian>

TEST_CASE("Unraid flash archives require both boot files at the volume root", "[unraid][archive]")
{
    Unraid::FlashArchiveContents contents;
    REQUIRE_FALSE(contents.isUnraid());

    SECTION("server backup")
    {
        contents.observeFile("config/ident.cfg");
        contents.observeFile("config/network.cfg");
        contents.observeFile("bzimage");
        REQUIRE_FALSE(contents.isUnraid());
        contents.observeFile("bzroot");
        REQUIRE(contents.isUnraid());
    }
    SECTION("FAT filenames are case insensitive and can have a dot prefix")
    {
        contents.observeFile("./BZROOT");
        contents.observeFile("./BzImage");
        REQUIRE(contents.isUnraid());
    }
    SECTION("nested boot files would not boot from the extracted volume")
    {
        contents.observeFile("backup/bzimage");
        contents.observeFile("backup/bzroot");
        REQUIRE_FALSE(contents.isUnraid());
    }
    SECTION("incomplete backup")
    {
        contents.observeFile("bzimage");
        contents.observeFile("bzroot-gui");
        REQUIRE_FALSE(contents.isUnraid());
    }
    SECTION("unrelated multi-file archive")
    {
        contents.observeFile("kernel.img");
        contents.observeFile("config.txt");
        REQUIRE_FALSE(contents.isUnraid());
    }
    SECTION("raw disk image ZIP")
    {
        contents.observeFile("unraid.img");
        REQUIRE_FALSE(contents.isUnraid());
    }
}

TEST_CASE("Detected flash backups get a real FAT volume label", "[unraid][archive][formatter]")
{
    Unraid::FlashArchiveContents contents;
    bool isBackup = false;
    SECTION("custom Unraid backup")
    {
        contents.observeFile("bzimage");
        contents.observeFile("bzroot");
        isBackup = true;
    }
    SECTION("unrelated archive keeps the formatter default")
    {
        contents.observeFile("kernel.img");
        contents.observeFile("config.txt");
    }

    QTemporaryDir directory;
    REQUIRE(directory.isValid());
    const QString path = directory.filePath("flash.img");
    rpi_imager::DiskFormatter formatter;
    if (contents.isUnraid())
        formatter.SetVolumeLabelOverride(Unraid::kInitFormat);
    REQUIRE(formatter.FormatFile(path.toStdString(), 64 * 1024 * 1024));

    QFile image(path);
    REQUIRE(image.open(QIODevice::ReadOnly));
    REQUIRE(image.seek(446));
    const auto partition = image.read(16);
    REQUIRE(partition.size() == 16);
    const quint64 partitionOffset = qFromLittleEndian<quint32>(partition.constData() + 8) * 512ULL;

    REQUIRE(image.seek(partitionOffset));
    const auto boot = image.read(512);
    REQUIRE(boot.size() == 512);
    const QByteArray expected = isBackup ? "UNRAID     " : "BOOT       ";
    REQUIRE(boot.mid(71, 11) == expected);

    // Linux's by-label lookup needs the root-directory label, not just BS_VolLab.
    const quint64 reserved = qFromLittleEndian<quint16>(boot.constData() + 14);
    const quint64 fatSize = qFromLittleEndian<quint32>(boot.constData() + 36);
    const quint64 rootCluster = qFromLittleEndian<quint32>(boot.constData() + 44);
    const quint64 rootSector = reserved + static_cast<quint8>(boot[16]) * fatSize
        + (rootCluster - 2) * static_cast<quint8>(boot[13]);
    REQUIRE(image.seek(partitionOffset + rootSector * 512));
    const auto labelEntry = image.read(32);
    REQUIRE(labelEntry.size() == 32);
    REQUIRE(labelEntry.left(11) == expected);
    REQUIRE(static_cast<quint8>(labelEntry[11]) == 0x08);
}
