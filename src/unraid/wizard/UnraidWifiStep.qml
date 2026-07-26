/*
 * SPDX-License-Identifier: Apache-2.0
 * Copyright (C) 2026 Lime Technology, Inc.
 *
 * UNRAID: Wi-Fi credentials for the server being created.
 *
 * Written to config/wireless.cfg by unraid_postwrite.cpp. That file is an INI
 * keyed by SSID and is consumed by etc/rc.d/rc.wireless in the webgui repo.
 *
 * This is NOT upstream's WifiCustomizationStep. Upstream PBKDF2-derives the PSK
 * for a wpa_supplicant.conf it writes itself; Unraid instead runs
 * wpa_passphrase over the *passphrase* at boot, so a derived key would be
 * double-hashed and the join would fail. We therefore keep the passphrase.
 *
 * On the password: rc.wireless expects the value openssl-encrypted with a key
 * derived from the target machine's DMI manufacturer and its wlan0 MAC, neither
 * of which is knowable here. It handles that — if decryption yields nothing it
 * treats the stored value as plaintext and re-writes it encrypted in place on
 * first boot. So writing plaintext is the supported path, not a workaround, but
 * it does mean the passphrase sits in clear text on the flash until first boot.
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../qmlcomponents"
import "../../wizard/components"

import RpiImager

WizardStepBase {
    id: root

    title: qsTr("Customisation: %1").arg(BrandSteps.wifiLabel)
    showSkipButton: true
    nextButtonAccessibleDescription: qsTr("Save Wi-Fi settings and continue")
    backButtonAccessibleDescription: qsTr("Return to previous step")
    skipButtonAccessibleDescription: qsTr("Skip all customisation and proceed directly to writing the image")

    property bool wifiEnabled: false

    // An open network legitimately has no password, so only require one when the
    // chosen security type actually uses it.
    readonly property bool needsPassword: fieldSecurity.currentValue !== "open"
    readonly property bool fieldsValid:
        fieldSsid.text.trim().length > 0 &&
        (!needsPassword || fieldPassword.text.length >= 8)

    nextButtonEnabled: !wifiEnabled || fieldsValid

    Component.onCompleted: {
        var s = wizardContainer.customizationSettings

        // Default to the country this machine is set to: writing the stick and
        // running the server in different regulatory domains is the rare case.
        // Qt.locale().name is like "en_US"; the territory half is the regdb code.
        var localeParts = Qt.locale().name.split("_")
        var hostRegion = localeParts.length > 1 ? localeParts[1] : ""
        var wanted = s.wifiRegion || hostRegion
        var ri = fieldRegion.find(wanted)
        fieldRegion.currentIndex = ri >= 0 ? ri : fieldRegion.find("US")
        if (s.wifiSSID) {
            root.wifiEnabled = true
            fieldSsid.text = s.wifiSSID
        }
        if (s.wifiPassword) fieldPassword.text = s.wifiPassword
        if (s.wifiSecurity) {
            var i = fieldSecurity.indexOfValue(s.wifiSecurity)
            if (i >= 0) fieldSecurity.currentIndex = i
        }
    }

    content: [
    ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: Style.sectionPadding
        spacing: Style.stepContentSpacing

        WizardSectionContainer {
            ImCheckBox {
                id: enableWifi
                text: qsTr("Connect this server to a Wi-Fi network")
                checked: root.wifiEnabled
                onToggled: root.wifiEnabled = checked
                Accessible.description: qsTr("Configure Wi-Fi instead of using a wired connection")
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: Style.spacingMedium
                rowSpacing: Style.formRowSpacing
                enabled: root.wifiEnabled
                opacity: enabled ? 1.0 : 0.5

                WizardFormLabel { text: qsTr("Network name (SSID):") }
                ImTextField {
                    id: fieldSsid
                    Layout.fillWidth: true
                    placeholderText: qsTr("Enter the Wi-Fi network name")
                    font.pointSize: Style.fontSizeInput
                    onTextChanged: root.commitSettings()
                    Accessible.description: qsTr("The name of the Wi-Fi network to join")
                }

                WizardFormLabel { text: qsTr("Security:") }
                ComboBox {
                    id: fieldSecurity
                    Layout.fillWidth: true
                    font.family: Style.fontFamily
                    font.pointSize: Style.fontSizeInput
                    textRole: "label"
                    valueRole: "value"
                    // Values are the SECURITY strings rc.wireless switches on.
                    model: [
                        { label: qsTr("WPA2 Personal"), value: "PSK" },
                        { label: qsTr("WPA3 Personal"), value: "SAE" },
                        { label: qsTr("Open network"),  value: "open" }
                    ]
                    currentIndex: 0
                    onCurrentValueChanged: root.commitSettings()
                    Accessible.description: qsTr("Security type used by the Wi-Fi network")
                }

                WizardFormLabel { text: qsTr("Wi-Fi region:") }
                ComboBox {
                    id: fieldRegion
                    Layout.fillWidth: true
                    font.family: Style.fontFamily
                    font.pointSize: Style.fontSizeInput
                    model: ImageWriterSingleton.getCountryList()
                    currentIndex: -1
                    onCurrentTextChanged: root.commitSettings()
                    Accessible.description: qsTr("Regulatory domain for the Wi-Fi radio")
                }

                WizardFormLabel { text: qsTr("Password:") }
                ImTextField {
                    id: fieldPassword
                    Layout.fillWidth: true
                    placeholderText: qsTr("Enter the Wi-Fi password")
                    font.pointSize: Style.fontSizeInput
                    echoMode: TextInput.Password
                    enabled: root.needsPassword
                    onTextChanged: root.commitSettings()
                    Accessible.description: qsTr("Password for the Wi-Fi network")
                }
            }

            WizardDescriptionText {
                text: root.wifiEnabled
                      ? qsTr("Stored in config/wireless.cfg on the flash drive. The password is held in plain text until the server first boots, which is when Unraid encrypts it.")
                      : qsTr("Leave this off if the server is connected by ethernet.")
            }
        }
    }
    ]

    // Committed as the user types: WizardContainer applies the customisation map
    // on entering the writing step, which can run before this step's own
    // onNextClicked. See UnraidNetworkStep.qml for the same reasoning.
    function commitSettings() {
        var s = wizardContainer.customizationSettings

        if (root.wifiEnabled && fieldSsid.text.trim().length > 0) {
            s.wifiSSID = fieldSsid.text.trim()
            s.wifiSecurity = fieldSecurity.currentValue
            s.wifiPassword = root.needsPassword ? fieldPassword.text : ""
            s.wifiRegion = fieldRegion.currentText
        } else {
            delete s.wifiSSID
            delete s.wifiSecurity
            delete s.wifiPassword
            delete s.wifiRegion
        }

        wizardContainer.customizationSettings = s
        wizardContainer.wifiConfigured = root.wifiEnabled && fieldSsid.text.trim().length > 0
    }

    onWifiEnabledChanged: commitSettings()
    onNextClicked: commitSettings()
}
