#ifndef DRIVELISTMODEL_H
#define DRIVELISTMODEL_H

/*
 * SPDX-License-Identifier: Apache-2.0
 * Copyright (C) 2020 Raspberry Pi Ltd
 */

#include <QAbstractItemModel>
#include <QMap>
#include <QHash>
#include <QQmlEngine>
#include "drivelistitem.h"
#include "drivelistmodelpollthread.h"

class DriveListModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("Created by C++")
public:
    DriveListModel(QObject *parent = nullptr);
    virtual int rowCount(const QModelIndex &) const;
    virtual QHash<int, QByteArray> roleNames() const;
    virtual QVariant data(const QModelIndex &index, int role) const;
    void startPolling();
    void stopPolling();

    enum driveListRoles
    {
        deviceRole = Qt::UserRole + 1,
        descriptionRole,
        sizeRole,
        isUsbRole,
        isScsiRole,
        isReadOnlyRole,
        isSystemRole,
        mountpointsRole,
        guidRole,
        guidValidRole
    };

public slots:
    void processDriveList(std::vector<Drivelist::DeviceDescriptor> l);

protected:
    QMap<QString, DriveListItem *> _drivelist;
    QHash<int, QByteArray> _rolenames;
    DriveListModelPollThread _thread;
    size_t _curl_write_callback(char *, size_t size, size_t nmemb, void *);
    size_t _curl_header_callback(void *, size_t size, size_t nmemb, void *);
};

#endif // DRIVELISTMODEL_H
