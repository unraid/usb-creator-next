#ifndef UNRAIDLANGUAGEMANAGER_H
#define UNRAIDLANGUAGEMANAGER_H

#include <QNetworkAccessManager>
#include <QObject>
#include <QUrl>

#include "config.h"

class UnraidLanguageManager : public QObject
{
    Q_OBJECT

public:
    explicit UnraidLanguageManager(QObject *parent = nullptr);

    // Language discovery
    void downloadUnraidLanguagesJson();
    QMap<QString, QString> getAvailableLanguages() const;
    QString getLanguageName(const QString &languageCode) const;
    QString getCurrentLanguageCode();
    void setCurrentLanguageCode(const QString &languageCode);

    // Language installation
    void installUnraidOSLanguage(const QString &languageCode, const QString &destinationPath);

signals:
    void progressUpdated(const QString &message);
    void languagesFetched();
    void xmlTemplateFetched();
    void zipUrlFetched();
    void languageZipInstalled();
    void error(const QString &errorMessage);
    void done();

private slots:
    void onLanguagesJsonDownloaded(QNetworkReply *reply);
    void onLanguageXmlDownloaded(QNetworkReply *reply);
    void onLanguageZipDownloaded(QNetworkReply *reply);

private:
    // helper methods

    QMap<QString, QString> parseLanguageMap(const QString &jsonPath);
    QString parseXmlUrlFromJson(const QString &code, const QString &jsonPath);
    QString parseLanguageUrlFromXml(const QString &xmlPath);

    void continueLanguageInstall(const QString &code, const QString &dest);
    void downloadLanguageXml(const QString &xmlUrl);
    void downloadLanguageZip(const QString &zipUrl);
    void patchDynamixConfig(const QString &langCode);

    // data members
    QUrl m_unraidLanguagesURL{UNRAID_LANGUAGES_URL};
    QNetworkAccessManager m_networkManager;
    QString m_currentLanguageCode;

    QString m_usbPath;
    QString m_jsonPath;
    QString m_xmlPath;
    QString m_zipPath;

    // Language cache
    QMap<QString, QString> m_availableLanguages; // code -> name mapping

protected:
};

#endif // UNRAIDLANGUAGEMANAGER_H
