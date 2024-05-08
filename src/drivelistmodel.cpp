/*
 * SPDX-License-Identifier: Apache-2.0
 * Copyright (C) 2020 Raspberry Pi Ltd
 */

#include "drivelistmodel.h"
#include "config.h"
#include "dependencies/drivelist/src/drivelist.hpp"
#include <QSet>
#include <QDebug>
#include <QUrl>
#include <curl/curl.h>

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
        {mountpointsRole, "mountpoints"},
        {guidRole, "guid"},
        {guidValidRole, "guidValid"}
    };

    // Enumerate drives in seperate thread, but process results in UI thread
    connect(&_thread, SIGNAL(newDriveList(std::vector<Drivelist::DeviceDescriptor>)), SLOT(processDriveList(std::vector<Drivelist::DeviceDescriptor>)));

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
    QLocale locale;

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
            QString guid{""};
            bool guidValid{true};
            if(!i.vid.empty() && !i.pid.empty() && !i.serialNumber.empty())
            {
                QString SerialPadded = QString::fromStdString(i.serialNumber).rightJustified(16, '0').right(16);
                guid = (QString::fromStdString(i.vid) + "-" +  QString::fromStdString(i.pid) + "-" + SerialPadded.left(4) + "-" + SerialPadded.mid(4)).toUpper();\

                CURL *curl;
                CURLcode res{CURLcode::CURLE_OK};
                long http_code{0};
                std::string data{""};
                curl = curl_easy_init();
                if(curl)
                {
                    curl_easy_setopt(curl, CURLOPT_CUSTOMREQUEST, "POST");
                    curl_easy_setopt(curl, CURLOPT_URL, UNRAID_GUID_URL);
                    curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);
                    curl_easy_setopt(curl, CURLOPT_DEFAULT_PROTOCOL, "https");
                    struct curl_slist *headers = NULL;
                    headers = curl_slist_append(headers, "Content-Type: application/x-www-form-urlencoded");
                    curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
                    data = "guid=" + guid.toStdString();
                    curl_easy_setopt(curl, CURLOPT_POSTFIELDS, data.c_str());
                    res = curl_easy_perform(curl);
                    curl_slist_free_all(headers);
                    curl_easy_getinfo (curl, CURLINFO_RESPONSE_CODE, &http_code);
                }
                curl_easy_cleanup(curl);

                if (res != CURLcode::CURLE_OK || http_code == 403)
                {
                    guidValid = false;
                }

            }

            _drivelist[deviceNamePlusSize] = new DriveListItem(QString::fromStdString(i.device), QString::fromStdString(i.description), i.size, guid, guidValid, i.isUSB, i.isSCSI, i.isReadOnly, mountpoints, this);
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

size_t DriveListModel::_curl_write_callback(char *, size_t size, size_t nmemb, void *)
{
    return size * nmemb;
}

size_t DriveListModel::_curl_header_callback(void *, size_t size, size_t nmemb, void *)
{
    return size*nmemb;
}
