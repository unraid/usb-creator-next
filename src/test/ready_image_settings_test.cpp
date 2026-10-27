/* SPDX-License-Identifier: Apache-2.0 */
#include "unraid/unraid_postwrite.h"
#include <QCoreApplication>
#include <QJsonDocument>
#include <iostream>

int main(int argc, char **argv)
{
    QCoreApplication app(argc, argv);
    const QVariantMap input{{"hostname", "storage"}, {"dhcp", false},
                            {"wifiSSID", "Home Wi-Fi"}, {"wifiPassword", "a$`\\\"secret"},
                            {"rootPassword", "must-not-export"}, {"accessToken", "must-not-export"},
                            {"sshAuthorizedKeys", "must-not-export"}};
    const auto data = Unraid::readyImageSettings(input);
    const auto object = QJsonDocument::fromJson(data).object();
    const auto settings = object.value("settings").toObject();
    if (object.value("schema") != "unraid.creator.v1" ||
        settings.value("hostname") != "storage" ||
        !settings.value("dhcp").isBool() || settings.value("dhcp").toBool() ||
        settings.value("wifiPassword").toString() != input.value("wifiPassword").toString() ||
        data.contains("must-not-export")) {
        std::cerr << "Ready-image settings changed values or exported unsupported secrets\n";
        return 1;
    }
    const auto defaults = QJsonDocument::fromJson(Unraid::readyImageSettings({})).object();
    if (!defaults.value("settings").toObject().value("dhcp").toBool())
        return 1;
    for (const auto &schema : {"unraid.ready-usb.v1", "unraid.ready-template.v2"}) {
        const QByteArray contract = QJsonDocument(QJsonObject{{"schema", schema}}).toJson();
        if (!Unraid::isFreshReadyImage(contract, false) ||
            Unraid::isFreshReadyImage(contract, true)) {
            std::cerr << "Ready-image schema admission or initialized-image refusal failed\n";
            return 1;
        }
    }
    for (const auto &invalid : {QByteArray("not JSON"), QByteArray("[]"), QByteArray("{}"),
                               QByteArray(R"({"schema":"unraid.ready-template.v3"})")}) {
        if (Unraid::isFreshReadyImage(invalid, false)) {
            std::cerr << "Unknown or malformed ready-image schema was admitted\n";
            return 1;
        }
    }
    std::cout << "Ready-image settings: values, boolean types, default DHCP and secret allowlist passed\n";
}
