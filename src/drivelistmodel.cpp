/*
 * SPDX-License-Identifier: Apache-2.0
 * Copyright (C) 2020 Raspberry Pi Ltd
 */

#include "drivelistmodel.h"
#include "config.h"
#include "dependencies/drivelist/src/drivelist.hpp"
#include <QSet>
#include <QDebug>
#include "libusb.h"


#include <iomanip>
#include <sstream>
#include <string>


DriveListModel::DriveListModel(QObject *parent)
    : QAbstractListModel(parent)
{
    _rolenames = {
        {deviceRole, "device"},
        {descriptionRole, "description"},
        {sizeRole, "size"},
        {isUsbRole, "isUsb"},
        {isScsiRole, "isScsi"},
        {isReadOnlyRole, "isReadOnly"},
        {mountpointsRole, "mountpoints"}
    };

    // Enumerate drives in seperate thread, but process results in UI thread
    connect(&_thread, SIGNAL(newDriveList(std::vector<Drivelist::DeviceDescriptor>)), SLOT(processDriveList(std::vector<Drivelist::DeviceDescriptor>)));

    libusb_context *context = NULL;
    libusb_device **list = NULL;
    int rc = 0;
    ssize_t count = 0;

    rc = libusb_init(&context);
    assert(rc == 0);

    count = libusb_get_device_list(context, &list);
    assert(count > 0);

    for (size_t idx = 0; idx < count; ++idx) {
        libusb_device *device = list[idx];
        libusb_device_descriptor desc = {0};

        rc = libusb_get_device_descriptor(device, &desc);
        assert(rc == 0);

        libusb_device_handle *handle;
        uint8_t data[33];
        qDebug() << "--------" << Qt::endl;
        QString tmp;
        try {
            libusb_open(device, &handle);
            if (handle != nullptr) {
                if (libusb_get_string_descriptor_ascii(handle, desc.iSerialNumber, data, 31) >= 0) {
                    data[32] = '\0';
                    std::ostringstream oss;
                    for(int i = 0; i < strlen(reinterpret_cast<const char*>(data)); ++i)
                    {
                        oss << std::hex << data[i];
                    }
                    qDebug() << "Serial Number: " << QString::fromStdString(oss.str()) << Qt::endl;
                    qDebug() << "Serial Number: " << QString::fromUtf8(reinterpret_cast<const char*>(data)) << Qt::endl;
                }
                if (libusb_get_string_descriptor_ascii(handle, desc.iManufacturer, data, 31) >= 0) {
                    data[32] = '\0';
                    std::ostringstream oss;
                    for(int i = 0; i < strlen(reinterpret_cast<const char*>(data)); ++i)
                    {
                        oss << std::hex << data[i];
                    }
                    qDebug() << "Manufacturer: " << QString::fromStdString(oss.str())  << Qt::endl;
                }
                if (libusb_get_string_descriptor_ascii(handle, desc.iProduct, data, 31) >= 0) {
                    data[32] = '\0';
                    std::ostringstream oss;
                    for(int i = 0; i < strlen(reinterpret_cast<const char*>(data)); ++i)
                    {
                        oss << std::hex << data[i];
                    }
                    qDebug() << "Product: " << QString::fromStdString(oss.str())  << Qt::endl;
                }

                //libusb_close(handle);
            }
        } catch (libusb_error &e) {
            qDebug() << e << Qt::endl;
        }
        qDebug() << "bDescriptorType" << desc.bDescriptorType << Qt::endl;
        qDebug() << "bDeviceClass" << desc.bDeviceClass << Qt::endl;
        qDebug() << "bDeviceSubClass" << desc.bDeviceSubClass << Qt::endl;
        qDebug() << "bDeviceProtocol" << desc.bDeviceProtocol << Qt::endl;
        qDebug() << "bcdDevice" << desc.bcdDevice << Qt::endl;
        qDebug() << "bLength" << desc.bLength << Qt::endl;
        qDebug() << "bMaxPacketSize0" << desc.bMaxPacketSize0 << Qt::endl;
        qDebug() << "bNumConfigurations" << desc.bNumConfigurations << Qt::endl;
        qDebug() << "iManufacturer" << desc.iManufacturer << Qt::endl;
        qDebug() << "idProduct" << tmp.setNum(desc.idProduct, 16) << Qt::endl;
        qDebug() << "iSerialNumber" << desc.iSerialNumber << Qt::endl;
        qDebug() << "idVendor" << tmp.setNum(desc.idVendor, 16) << Qt::endl;

    }

    libusb_free_device_list(list, 1);
    libusb_exit(context);
}

int DriveListModel::rowCount(const QModelIndex &) const
{
    return _drivelist.count();
}

QHash<int, QByteArray> DriveListModel::roleNames() const
{
    return _rolenames;
}

QVariant DriveListModel::data(const QModelIndex &index, int role) const
{
    int row = index.row();
    if (row < 0 || row >= _drivelist.count())
        return QVariant();

    QByteArray propertyName = _rolenames.value(role);
    if (propertyName.isEmpty())
        return QVariant();
    else
        return _drivelist.values().at(row)->property(propertyName);
}

void DriveListModel::processDriveList(std::vector<Drivelist::DeviceDescriptor> l)
{
    bool changes = false;
    bool filterSystemDrives = DRIVELIST_FILTER_SYSTEM_DRIVES;
    QSet<QString> drivesInNewList;

    for (auto &i: l)
    {
        // Convert STL vector<string> to Qt QStringList
        QStringList mountpoints;
        for (auto &s: i.mountpoints)
        {
            mountpoints.append(QString::fromStdString(s));
        }

        if (filterSystemDrives)
        {
            if (i.isSystem)
                continue;
        }
        // Should already be caught by isSystem variable, but just in case...
        if (mountpoints.contains("/") || mountpoints.contains("C://"))
            continue;

        // Skip zero-sized devices
        if (i.size == 0)
            continue;

#ifdef Q_OS_DARWIN
        if (i.isVirtual)
            continue;
#endif

        QString deviceNamePlusSize = QString::fromStdString(i.device)+":"+QString::number(i.size);
        if (i.isReadOnly)
            deviceNamePlusSize += "ro";
        drivesInNewList.insert(deviceNamePlusSize);

        if (!_drivelist.contains(deviceNamePlusSize))
        {
            // Found new drive
            if (!changes)
            {
                beginResetModel();
                changes = true;
            }

            _drivelist[deviceNamePlusSize] = new DriveListItem(QString::fromStdString(i.device), QString::fromStdString(i.description), i.size, i.isUSB, i.isSCSI, i.isReadOnly, mountpoints, this);
        }
    }

    // Look for drives removed
    QStringList drivesInOldList = _drivelist.keys();
    for (auto &device: drivesInOldList)
    {
        if (!drivesInNewList.contains(device))
        {
            if (!changes)
            {
                beginResetModel();
                changes = true;
            }

            _drivelist.value(device)->deleteLater();
            _drivelist.remove(device);
        }
    }

    if (changes)
        endResetModel();
}

void DriveListModel::startPolling()
{
    _thread.start();
}

void DriveListModel::stopPolling()
{
    _thread.stop();
}
