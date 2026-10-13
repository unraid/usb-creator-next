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
    std::cout << "Ready-image settings: values, boolean types, default DHCP and secret allowlist passed\n";
}
