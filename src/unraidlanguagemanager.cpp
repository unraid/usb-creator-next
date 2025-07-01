#include "unraidlanguagemanager.h"

#include <QCoreApplication>
#include <QFile>
#include <QFileInfo>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonParseError>
#include <QJsonValue>
#include <QNetworkReply>
#include <QRegularExpression>
#include <QSettings>
#include <QXmlStreamReader>

UnraidLanguageManager::UnraidLanguageManager(QObject *parent)
    : QObject(parent)
    , m_networkManager()
{}

// --- public methods ---

void UnraidLanguageManager::downloadUnraidLanguagesJson()
{
    //get the URL
    //send HTTP Request
    //Get results
    // If good, store/overwrite JSON file to temp location where App is running
    // If not good, send error

    emit progressUpdated("Downloading JSON file containing supported language information...");

    QNetworkRequest request(m_unraidLanguagesURL);
    QNetworkReply *jsonReply = m_networkManager.get(request);

    QObject::connect(jsonReply, &QNetworkReply::finished, this, [this, jsonReply]() {
        onLanguagesJsonDownloaded(jsonReply);
    });
}

QMap<QString, QString> UnraidLanguageManager::getAvailableLanguages() const
{
    return m_availableLanguages;
}

QString UnraidLanguageManager::getLanguageName(const QString &languageCode) const
{
    return m_currentLanguageCode;
}

void UnraidLanguageManager::installUnraidOSLanguage(const QString &languageCode,
                                                    const QString &destinationPath)
{
    m_currentLanguageCode = languageCode;
    m_usbPath = destinationPath;

    emit progressUpdated("Searching for language json...");

    qDebug() << "m_availableLanguage is empty:" << m_availableLanguages.empty();

    if (m_availableLanguages.empty()) {
        emit progressUpdated("Couldn't find language json, installing...");

        // can change back to Qt::SingleShotConnection after rebasing to QT 6
        QMetaObject::Connection conn;
        conn = connect(this, &UnraidLanguageManager::languagesFetched, this, [=]() {
            continueLanguageInstall(languageCode, destinationPath);
            disconnect(conn);
        });
        downloadUnraidLanguagesJson();
        return;
    }

    emit progressUpdated("Starting language installation...");
    continueLanguageInstall(languageCode, destinationPath);
}

// --- private slots ---

// gets data from http request, writes locally, parses json language map, emits languagesFetched signal
void UnraidLanguageManager::onLanguagesJsonDownloaded(QNetworkReply *reply)
{
    if (reply->error() != QNetworkReply::NoError) {
        emit error(QString("Network error fetching Unraid Languages: %1").arg(reply->errorString()));
    } else {
        int status = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        qDebug() << "[HTTP]" << status;

        QByteArray jsonData = reply->readAll();

        m_jsonPath = QCoreApplication::applicationDirPath() + "/unraid-os-languages.json";
        QFile f(m_jsonPath);
        if (!f.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
            emit error(QString("Couldn’t write JSON to %1").arg(f.fileName()));
        } else {
            f.write(jsonData);
            f.close();
        }

        emit progressUpdated(
            "Downloading JSON file containing supported language information...[done]");
        qDebug() << "Wrote Languages Unraid OS Currently Supports to:" << f.fileName();

        emit progressUpdated("Parsing JSON file containing supported language information...");
        m_availableLanguages = parseLanguageMap(m_jsonPath);
        emit progressUpdated(
            "Parsing JSON file containing supported language information...[done]");

        emit languagesFetched();
    }

    reply->deleteLater();
}

void UnraidLanguageManager::onLanguageXmlDownloaded(QNetworkReply *reply)
{
    QString zipUrl;

    if (reply->error() != QNetworkReply::NoError) {
        emit error(QString("Network error fetching requested language's XML template: %1")
                       .arg(reply->errorString()));
    } else {
        int status = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        qDebug() << "[HTTP]" << status;

        QByteArray xmlData = reply->readAll();

        m_xmlPath = m_usbPath + "/config/plugins/lang-" + m_currentLanguageCode + ".xml";

        QFile f(m_xmlPath);
        if (!f.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
            emit error(
                QString("Couldn’t write required language's XML template to %1").arg(f.fileName()));
        } else {
            f.write(xmlData);
            f.close();
        }
        emit progressUpdated("Fetching XML template file for requested language...[done]");
        qDebug() << "Wrote requested language's XML template to:" << f.fileName();
        emit zipUrlFetched();
    }

    reply->deleteLater();
}

void UnraidLanguageManager::onLanguageZipDownloaded(QNetworkReply *reply)
{
    if (reply->error() != QNetworkReply::NoError) {
        emit error(QString("Network error fetching requested language's zip file: %1")
                       .arg(reply->errorString()));
    } else {
        int status = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        qDebug() << "[HTTP]" << status;

        QByteArray zipData = reply->readAll();

        m_zipPath = m_usbPath + "/config/plugins/dynamix/lang-" + m_currentLanguageCode + ".zip";

        QFile f(m_zipPath);
        if (!f.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
            emit error(
                QString("Couldn’t write required language's zip file to %1").arg(f.fileName()));
        } else {
            f.write(zipData);
            f.close();
        }
        emit progressUpdated("Fetching requested language zip...[done]");
        qDebug() << "Wrote requested language's zip file to:" << f.fileName();
        emit languageZipInstalled();
    }

    reply->deleteLater();
}

// --- private methods ---
void UnraidLanguageManager::continueLanguageInstall(const QString &langCode, const QString &dest)
{
    // can change back to Qt::SingleShotConnection after rebasing to QT 6
    QMetaObject::Connection zipConn;
    zipConn = connect(this, &UnraidLanguageManager::zipUrlFetched, this, [=]() {
        emit progressUpdated("Parsing XML template file for requested language...");
        QString zipUrl = parseLanguageUrlFromXml(m_xmlPath);
        emit progressUpdated("Parsing XML template file for requested language...[done]");
        downloadLanguageZip(zipUrl);
        disconnect(zipConn);
    });

    QMetaObject::Connection installConn;
    connect(this, &UnraidLanguageManager::languageZipInstalled, this, [=]() {
        emit progressUpdated("Patching Unraid OS language config file...");
        patchDynamixConfig(langCode);
        emit progressUpdated("Patching Unraid OS language config file...[done]");
        emit progressUpdated("Unraid OS language installation complete.");
        disconnect(installConn);
    });

    QString xmlUrl = parseXmlUrlFromJson(m_jsonPath, langCode);
    qDebug() << "xmlUrl = " << xmlUrl;
    downloadLanguageXml(xmlUrl);
}

QMap<QString, QString> UnraidLanguageManager::parseLanguageMap(const QString &jsonPath)
{
    QFile f(jsonPath);
    if (!f.open(QIODevice::ReadOnly)) {
        emit error(QString("Could not open %1: %2").arg(jsonPath, f.errorString()));
        return {};
    }
    QByteArray raw = f.readAll();
    if (f.error() != QFileDevice::NoError) {
        emit error(QString("Error reading %1: %2").arg(jsonPath, f.errorString()));
        return {};
    }
    f.close();

    QJsonParseError err;
    auto doc = QJsonDocument::fromJson(raw, &err);
    if (err.error != QJsonParseError::NoError || !doc.isObject()) {
        emit error(QString("JSON parse error in %1: %2").arg(jsonPath, err.errorString()));
        return {};
    }

    QMap<QString, QString> map;

    for (auto code : doc.object().keys()) {
        auto entry = doc.object().value(code).toObject();
        QString rawDesc = entry.value("Desc").toString().trimmed();
        int idx = rawDesc.indexOf('(');
        QString cleanName = (idx > 0) ? rawDesc.left(idx).trimmed() : rawDesc;

        map.insert(code, cleanName);
    }
    return map;
}

QString UnraidLanguageManager::parseXmlUrlFromJson(const QString &jsonPath, const QString &code)
{
    emit progressUpdated("Parsing JSON file containing supported languages...");

    QFile f(jsonPath);
    if (!f.open(QIODevice::ReadOnly)) {
        emit error(QString("Could not open %1").arg(jsonPath));
        return {};
    }

    QJsonParseError err;
    auto doc = QJsonDocument::fromJson(f.readAll(), &err);
    f.close();

    if (err.error != QJsonParseError::NoError || !doc.isObject()) {
        emit error(QString("JSON parse error in %1: %2").arg(jsonPath, err.errorString()));
        return {};
    }

    QJsonObject root = doc.object();
    if (!root.contains(code)) {
        emit error(QString("Language code %1 not found in %2").arg(code, jsonPath));
        return {};
    }

    QJsonObject entry = root.value(code).toObject();
    emit progressUpdated("Parsing JSON file containing supported languages...[done]");
    return entry.value("URL").toString();
}

void UnraidLanguageManager::downloadLanguageXml(const QString &xmlUrl)
{
    emit progressUpdated("Fetching XML template file for requested language...");

    QNetworkRequest request(xmlUrl);
    QNetworkReply *xmlReply = m_networkManager.get(request);

    QObject::connect(xmlReply, &QNetworkReply::finished, this, [this, xmlReply]() {
        onLanguageXmlDownloaded(xmlReply);
    });
}

QString UnraidLanguageManager::parseLanguageUrlFromXml(const QString &xmlPath)
{
    emit progressUpdated("Parsing XML file to download requested language...");

    QFile f(xmlPath);
    if (!f.open(QIODevice::ReadOnly)) {
        emit error(QString("Could not open %1").arg(xmlPath));
        return {};
    }

    QXmlStreamReader xml(&f);

    while (!xml.atEnd()) {
        xml.readNext();
        if (xml.isStartElement() && xml.name() == QLatin1String("LanguageURL")) {
            QString url = xml.readElementText().trimmed();
            if (url.isEmpty()) {
                emit error("Empty <LanguageURL> in XML");
            }
            emit xmlTemplateFetched();
            qDebug() << url;
            return url;
        }
    }

    if (xml.hasError()) {
        emit error(QString("XML parse error in %1: %2").arg(xmlPath, xml.errorString()));
    } else {
        emit error(QString("No <LanguageURL> tag found in %1").arg(xmlPath));
    }
    return {};
}

void UnraidLanguageManager::downloadLanguageZip(const QString &zipUrl)
{
    emit progressUpdated("Fetching requested language zip...");

    QNetworkRequest request(zipUrl);
    QNetworkReply *zipReply = m_networkManager.get(request);

    QObject::connect(zipReply, &QNetworkReply::finished, this, [this, zipReply]() {
        onLanguageZipDownloaded(zipReply);
    });
}

/*
 * Since QSettings strips literal quotes in INI values, we:
 * 1) Wrap the value in a unique marker (e.g. "__QUOTE__")
 * 2) Let QSettings write the file normally
 * 3) After sync, reopen the INI and replace marker + value + marker → "value"
 * This restores real quotation marks in the final file.
 */

void UnraidLanguageManager::patchDynamixConfig(const QString &languageCode)
{
    qDebug("went into patchDynamixConfig");

    const QString cfgPath = m_usbPath + "/config/plugins/dynamix/dynamix.cfg";

    // Marker must be something that will NEVER appear in your real data
    const QString quoteMarker = "__QUOTE__";

    QString placeholderValue = quoteMarker + languageCode + quoteMarker;

    if (!QFile::exists(cfgPath)) {
        qWarning() << "Config file does not exist:" << cfgPath;
        emit done();
        return;
    }

    {
        QSettings settings(cfgPath, QSettings::IniFormat);

        settings.beginGroup("display");
        settings.setValue("locale", placeholderValue);
        settings.endGroup();

        settings.sync();

        // Check if sync was successful
        QSettings::Status status = settings.status();
        switch (status) {
        case QSettings::NoError:
            qDebug() << "Successfully patched config file:" << cfgPath;
            break;
        case QSettings::AccessError:
            qWarning() << "Access error writing to:" << cfgPath;
            // Try to get more specific error information
            if (!QFileInfo(cfgPath).isWritable()) {
                qWarning() << "File is not writable (permissions issue)";
            }
            break;
        case QSettings::FormatError:
            qWarning() << "Format error in file:" << cfgPath;
            break;
        default:
            qWarning() << "Unknown error occurred while writing to:" << cfgPath
                       << "Status code:" << status;

            // Additional diagnostic information
            QFileInfo fileInfo(cfgPath);
            qWarning() << "File exists:" << fileInfo.exists()
                       << "Is readable:" << fileInfo.isReadable()
                       << "Is writable:" << fileInfo.isWritable()
                       << "File size:" << fileInfo.size();
            break;
        }
    }

    // Post-process the file: swap marker → real quotes
    {
        QFile file(cfgPath);
        if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
            qWarning() << "Could not reopen for post-processing:" << cfgPath;
        } else {
            QString contents = QString::fromUtf8(file.readAll());
            file.close();

            // Replace __QUOTE__langCode__QUOTE__ → "langCode"
            const QString target = quoteMarker + languageCode + quoteMarker;
            const QString replaced = QString("\"%1\"").arg(languageCode);
            contents.replace(target, replaced);

            if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate | QIODevice::Text)) {
                qWarning() << "Could not reopen for writing swapped INI:" << cfgPath;
            } else {
                file.write(contents.toUtf8());
                file.close();
                qDebug() << "Patched quotes in INI to actual quotation marks.";
            }
        }
    }

    emit done();
}
