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
    void requestUnraidLanguagesJson();
    QMap<QString, QString> getAvailableLanguages() const;
    QString getLanguageName(const QString &languageCode) const;
    QString getCurrentLanguageCode();
    void setCurrentLanguageCode(const QString &languageCode);

    // Language installation
    void installUnraidOSLanguage(const QString &languageCode, const QString &destinationPath);

signals:
    void progressUpdated(const QString &message);
    void languagesFetched();
    void xmlFetched();
    void languageZipInstalled();
    void error(const QString &errorMessage);
    void done();

private slots:

    void onLanguagesJsonFetched();
    void onLanguageXmlReady();
    void onLanguageZipReady();

    void onLanguagesJsonRequest(QNetworkReply *reply);
    void onLanguageXmlRequest(QNetworkReply *reply);
    void onLanguageZipRequest(QNetworkReply *reply);

private:
    // helper methods

    QMap<QString, QString> parseLanguageMap(const QString &jsonPath);
    QString parseXmlUrlFromJson(const QString &code, const QString &jsonPath);
    QString parseLanguageUrlFromXml(const QString &xmlPath);

    void continueLanguageInstall(const QString &code, const QString &dest);
    void requestLanguageXml(const QString &xmlUrl);
    void requestLanguageZip(const QString &zipUrl);
    void patchDynamixConfig(const QString &langCode);

    // data members
    QUrl m_unraidLanguagesURL{UNRAID_LANGUAGES_URL};
    QNetworkAccessManager m_networkManager;
    QString m_currentLanguageCode;

    QString m_usbPath;
    QString m_jsonPath;
    QString m_xmlPath;
    QString m_zipPath;
    bool m_installPending;

    // Language cache
    QMap<QString, QString> m_availableLanguages; // code -> name mapping

protected:
};

#endif // UNRAIDLANGUAGEMANAGER_H
