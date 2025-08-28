//
#pragma once
#include <QString>
#include <QStringList>
#if defined(_WIN32)
QStringList whoIsUsingPath(const QString &rootPath); // e.g. "H:\\"
#endif