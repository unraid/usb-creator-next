#ifndef SECUREBOOT_H
#define SECUREBOOT_H

/*
 * SPDX-License-Identifier: Apache-2.0
 * Copyright (C) 2025 Raspberry Pi Ltd
 */

#include <QByteArray>
#include <QString>
#include <QMap>

class DeviceWrapperFatPartition;

class SecureBoot
{
public:
    SecureBoot();
    ~SecureBoot();

    /**
     * Extract all files from a FAT32 partition into a memory map
     * @param fat The FAT partition to extract from
     * @return Map of filename -> file contents
     */
    static QMap<QString, QByteArray> extractFatPartitionFiles(DeviceWrapperFatPartition *fat);

    /**
     * Create a FAT32 boot.img file from a map of files
     * @param files Map of filename -> file contents
     * @param outputPath Path where boot.img should be created
     * @return true on success, false on error
     */
    static bool createBootImg(const QMap<QString, QByteArray> &files, const QString &outputPath);

    /**
     * Generate boot.sig signature file for a boot.img
     * @param bootImgPath Path to the boot.img file
     * @param rsaKeyPath Path to RSA 2048-bit private key (PEM format)
     * @param bootSigPath Path where boot.sig should be created
     * @return true on success, false on error
     */
    static bool generateBootSig(const QString &bootImgPath, const QString &rsaKeyPath, const QString &bootSigPath);

    /**
     * Build a bootconf.sig blob for an in-memory config buffer.  The
     * format matches rpi-eeprom-digest output: hex sha256, "ts: <epoch>",
     * "rsa2048: <hex sig>", separated by newlines.  Used to embed an
     * RSA-signed config inside an EEPROM image.
     */
    static QByteArray generateConfigSig(const QByteArray &configText, const QString &rsaKeyPath);

    /**
     * Extract the public-key components (N, E) from a PEM-encoded RSA-2048
     * private (or public) key and return them in the 264-byte little-endian
     * format used by the Pi bootloader: 256 bytes of N || 8 bytes of E.
     * Returns empty on error.
     */
    static QByteArray extractRsaPubkeyBin(const QString &rsaKeyPath);

    /**
     * Counter-sign a bootcode binary for the BCM2712 boot ROM.  Wraps the
     * bootcode with [bootcode][u32_le len][u32_le keynum][u32_le version]
     * [256-byte RSA-2048 PKCS#1v1.5 signature over the preceding bytes]
     * [264-byte pubkey.bin].  keynum is 16 for customer signing, version
     * is 0 unless rollback protection is being used.  Returns empty on error.
     */
    static QByteArray signBootcode2712(const QByteArray &bootcode,
                                       const QString &rsaKeyPath,
                                       int keynum = 16,
                                       int version = 0);

    /**
     * Generate SHA-256 hash of a file
     * @param filePath Path to the file
     * @return Hex-encoded SHA-256 hash, or empty on error
     */
    static QByteArray sha256File(const QString &filePath);

    /**
     * Sign data with RSA PKCS#1 v1.5 using a private key
     * @param data Data to sign
     * @param rsaKeyPath Path to RSA private key (PEM format)
     * @return Hex-encoded signature, or empty on error
     */
    static QByteArray rsaSign(const QByteArray &data, const QString &rsaKeyPath);

    /**
     * Get current Unix timestamp
     * @return Current timestamp as seconds since epoch
     */
    static qint64 getCurrentTimestamp();
};

#endif // SECUREBOOT_H


