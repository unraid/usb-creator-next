/*
 * SPDX-License-Identifier: Apache-2.0
 * Copyright (C) 2026 Lime Technology, Inc.
 *
 * UNRAID: network addressing for the server being created.
 *
 * These values are written to config/network.cfg on the flash by
 * unraid_postwrite.cpp (USE_DHCP / IPADDR / NETMASK / GATEWAY / DNS_SERVER1).
 * The keys below must stay in step with the ones that file reads.
 *
 * This occupies the wizard slot upstream uses for its User step: Unraid has no
 * username to choose, and the root password is set from the webGUI on first
 * boot rather than staged on the flash. See BrandSteps.qml.
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../qmlcomponents"
import "../../wizard/components"

import RpiImager

WizardStepBase {
    id: root

    title: qsTr("Customisation: %1").arg(BrandSteps.networkConfigLabel)
    showSkipButton: true
    nextButtonAccessibleDescription: qsTr("Save network settings and continue")
    backButtonAccessibleDescription: qsTr("Return to previous step")
    skipButtonAccessibleDescription: qsTr("Skip all customisation and proceed directly to writing the image")

    // DHCP is the default because it is what an unconfigured Unraid server does;
    // a user only reaches the static fields deliberately.
    property bool useDhcp: true

    // UNRAID: shared by the wired and Wi-Fi netmask pickers so the two cannot
    // drift apart.
    readonly property var netmaskOptions: [
        "255.255.0.0", "255.255.128.0", "255.255.192.0", "255.255.224.0",
        "255.255.240.0", "255.255.248.0", "255.255.252.0", "255.255.254.0",
        "255.255.255.0", "255.255.255.128", "255.255.255.192",
        "255.255.255.224", "255.255.255.240", "255.255.255.248",
        "255.255.255.252"
    ]

    readonly property bool staticFieldsValid:
        fieldIpAddr.acceptableInput && fieldGateway.acceptableInput && fieldDns.acceptableInput

    // UNRAID: whether the Wi-Fi step was filled in. Drives the second address
    // group below -- Wi-Fi is asked first so this is already known.
    readonly property bool wifiConfigured:
        wizardContainer && wizardContainer.customizationSettings
        && (wizardContainer.customizationSettings.wifiSSID || "") !== ""

    readonly property bool wifiStaticFieldsValid:
        fieldWifiIpAddr.acceptableInput && fieldWifiGateway.acceptableInput
        && fieldWifiDns.acceptableInput

    // Two interfaces holding one address is the bug this exists to prevent, so
    // an identical address is rejected rather than quietly written to both.
    readonly property bool wifiAddressClashes:
        fieldWifiIpAddr.text !== "" && fieldWifiIpAddr.text === fieldIpAddr.text

    // DHCP needs no input; static addressing must be complete before Next unlocks,
    // since a partial network.cfg would leave the server unreachable. When Wi-Fi is
    // also configured its address must be complete and distinct.
    nextButtonEnabled: useDhcp
                       || (staticFieldsValid
                           && (!wifiConfigured || (wifiStaticFieldsValid && !wifiAddressClashes)))

    Component.onCompleted: {
        var s = wizardContainer.customizationSettings
        if (typeof s.dhcp !== "undefined") {
            root.useDhcp = s.dhcp
        }
        if (s.ipaddr) fieldIpAddr.text = s.ipaddr
        if (s.gateway) fieldGateway.text = s.gateway
        if (s.dns) fieldDns.text = s.dns
        if (s.netmask) {
            var i = fieldNetmask.find(s.netmask)
            if (i >= 0) fieldNetmask.currentIndex = i
        }
        // UNRAID: restore the Wi-Fi address too, so going back and forward does
        // not silently drop it.
        if (s.wifiIpaddr) fieldWifiIpAddr.text = s.wifiIpaddr
        if (s.wifiGateway) fieldWifiGateway.text = s.wifiGateway
        if (s.wifiDns) fieldWifiDns.text = s.wifiDns
        if (s.wifiNetmask) {
            var wi = fieldWifiNetmask.find(s.wifiNetmask)
            if (wi >= 0) fieldWifiNetmask.currentIndex = wi
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
            RowLayout {
                Layout.fillWidth: true
                spacing: Style.spacingLarge

                ImRadioButton {
                    id: radioDhcp
                    text: qsTr("Automatic (DHCP)")
                    checked: root.useDhcp
                    onClicked: root.useDhcp = true
                    Accessible.description: qsTr("Let the server obtain its address from your router")
                }

                ImRadioButton {
                    id: radioStatic
                    text: qsTr("Static IP")
                    checked: !root.useDhcp
                    onClicked: root.useDhcp = false
                    Accessible.description: qsTr("Assign a fixed address to this server")
                }
            }

            // UNRAID: one label column, with the wired address and (when Wi-Fi is
            // set up) the Wi-Fi address side by side.
            //
            // Stacking the two groups vertically overflowed the step -- the content
            // area is a plain Item with no clipping or scrolling, so the extra rows
            // drew over the title and the navigation buttons. Sharing the labels
            // halves the height and reads better besides.
            //
            // Rows and columns are assigned explicitly: a GridLayout skips
            // invisible items, so the Wi-Fi column would otherwise reflow into the
            // wired one whenever Wi-Fi is not configured.
            GridLayout {
                Layout.fillWidth: true
                columns: 3
                columnSpacing: Style.spacingMedium
                rowSpacing: Style.formRowSpacing
                enabled: !root.useDhcp
                opacity: enabled ? 1.0 : 0.5

                // Column headers, only meaningful once there are two columns.
                Item { Layout.row: 0; Layout.column: 0; visible: root.wifiConfigured }
                WizardDescriptionText {
                    Layout.row: 0; Layout.column: 1
                    visible: root.wifiConfigured
                    text: qsTr("Wired")
                    font.family: Style.fontFamilyBold
                    font.bold: true
                }
                WizardDescriptionText {
                    Layout.row: 0; Layout.column: 2
                    visible: root.wifiConfigured
                    text: BrandSteps.wifiLabel
                    font.family: Style.fontFamilyBold
                    font.bold: true
                }

                WizardFormLabel { Layout.row: 1; Layout.column: 0; text: qsTr("IP address:") }
                ImTextField {
                    id: fieldIpAddr
                    Layout.row: 1; Layout.column: 1
                    onTextChanged: root.commitSettings()
                    Layout.fillWidth: true
                    placeholderText: "192.168.1.10"
                    font.pointSize: Style.fontSizeInput
                    validator: RegularExpressionValidator { regularExpression: root.ipv4Regex }
                    Accessible.description: qsTr("Fixed IPv4 address for the wired connection")
                }
                ImTextField {
                    id: fieldWifiIpAddr
                    Layout.row: 1; Layout.column: 2
                    visible: root.wifiConfigured
                    onTextChanged: root.commitSettings()
                    Layout.fillWidth: true
                    placeholderText: "192.168.1.11"
                    font.pointSize: Style.fontSizeInput
                    validator: RegularExpressionValidator { regularExpression: root.ipv4Regex }
                    Accessible.description: qsTr("Fixed IPv4 address for the Wi-Fi connection, which must differ from the wired address")
                }

                WizardFormLabel { Layout.row: 2; Layout.column: 0; text: qsTr("Netmask:") }
                ComboBox {
                    id: fieldNetmask
                    Layout.row: 2; Layout.column: 1
                    Layout.fillWidth: true
                    font.family: Style.fontFamily
                    font.pointSize: Style.fontSizeInput
                    model: root.netmaskOptions
                    currentIndex: -1
                    Component.onCompleted: currentIndex = find("255.255.255.0")
                    onCurrentTextChanged: root.commitSettings()
                    Accessible.description: qsTr("Subnet mask for the wired connection")
                }
                ComboBox {
                    id: fieldWifiNetmask
                    Layout.row: 2; Layout.column: 2
                    visible: root.wifiConfigured
                    Layout.fillWidth: true
                    font.family: Style.fontFamily
                    font.pointSize: Style.fontSizeInput
                    model: root.netmaskOptions
                    currentIndex: -1
                    Component.onCompleted: currentIndex = find("255.255.255.0")
                    onCurrentTextChanged: root.commitSettings()
                    Accessible.description: qsTr("Subnet mask for the Wi-Fi connection")
                }

                WizardFormLabel { Layout.row: 3; Layout.column: 0; text: qsTr("Gateway:") }
                ImTextField {
                    id: fieldGateway
                    Layout.row: 3; Layout.column: 1
                    onTextChanged: root.commitSettings()
                    Layout.fillWidth: true
                    placeholderText: "192.168.1.1"
                    font.pointSize: Style.fontSizeInput
                    validator: RegularExpressionValidator { regularExpression: root.ipv4Regex }
                    Accessible.description: qsTr("Router address for the wired connection")
                }
                ImTextField {
                    id: fieldWifiGateway
                    Layout.row: 3; Layout.column: 2
                    visible: root.wifiConfigured
                    onTextChanged: root.commitSettings()
                    Layout.fillWidth: true
                    placeholderText: "192.168.1.1"
                    font.pointSize: Style.fontSizeInput
                    validator: RegularExpressionValidator { regularExpression: root.ipv4Regex }
                    Accessible.description: qsTr("Router address for the Wi-Fi connection")
                }

                WizardFormLabel { Layout.row: 4; Layout.column: 0; text: qsTr("DNS server:") }
                ImTextField {
                    id: fieldDns
                    Layout.row: 4; Layout.column: 1
                    onTextChanged: root.commitSettings()
                    Layout.fillWidth: true
                    placeholderText: "192.168.1.1"
                    font.pointSize: Style.fontSizeInput
                    validator: RegularExpressionValidator { regularExpression: root.ipv4Regex }
                    Accessible.description: qsTr("DNS server for the wired connection")
                }
                ImTextField {
                    id: fieldWifiDns
                    Layout.row: 4; Layout.column: 2
                    visible: root.wifiConfigured
                    onTextChanged: root.commitSettings()
                    Layout.fillWidth: true
                    placeholderText: "192.168.1.1"
                    font.pointSize: Style.fontSizeInput
                    validator: RegularExpressionValidator { regularExpression: root.ipv4Regex }
                    Accessible.description: qsTr("DNS server for the Wi-Fi connection")
                }
            }

            // The whole point of the second address is that it is a different one.
            WizardDescriptionText {
                visible: !root.useDhcp && root.wifiConfigured && root.wifiAddressClashes
                text: qsTr("The Wi‑Fi address must be different from the wired address.")
                color: Style.raspberryRed
            }

            WizardDescriptionText {
                // UNRAID: kept to a single line. The step has no room to spare --
                // two lines already clip behind the navigation buttons, and the
                // clash warning above needs a line of its own. See the Wi-Fi
                // section of unraid_postwrite.cpp for why the addresses differ.
                text: root.useDhcp
                      ? qsTr("The server will request an address from your router when it boots.")
                      : root.wifiConfigured
                        ? qsTr("Each connection needs its own address.")
                        : qsTr("These settings are written to config/network.cfg on the flash drive.")
            }
        }
    }
    ]

    // Each octet 0-255, rejecting things like 999 or 1.2.3 that a plain \d{1,3}
    // pattern would let through.
    readonly property var ipv4Regex:
        /^((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\.){3}(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)$/

    // Commit on every change rather than only on Next.
    //
    // WizardContainer.nextStep() calls applyCustomisationFromSettings() as it
    // enters the writing step, and the instantiation-site onNextClicked handler
    // (which calls nextStep()) races with this step's own handler. Committing as
    // the user types means the map is already correct whichever order they run in
    // — otherwise the static address is silently dropped and network.cfg is left
    // on DHCP while the summary still reports "Network configured".
    function commitSettings() {
        var s = wizardContainer.customizationSettings
        s.dhcp = root.useDhcp

        if (root.useDhcp) {
            // Clear rather than leave stale values behind: unraid_postwrite only
            // writes the static keys when they are all present, and a half-populated
            // network.cfg would leave the server unreachable.
            s.ipaddr = ""
            s.netmask = ""
            s.gateway = ""
            s.dns = ""
            s.static = false
        } else {
            s.ipaddr = fieldIpAddr.text
            s.netmask = fieldNetmask.currentText
            s.gateway = fieldGateway.text
            s.dns = fieldDns.text
            s.static = true
        }

        // UNRAID: the Wi-Fi address is separate and only meaningful when Wi-Fi was
        // set up and addressing is static. Cleared otherwise, so wireless.cfg falls
        // back to DHCP rather than picking up a stale address from an earlier pass.
        if (!root.useDhcp && root.wifiConfigured && !root.wifiAddressClashes) {
            s.wifiIpaddr = fieldWifiIpAddr.text
            s.wifiNetmask = fieldWifiNetmask.currentText
            s.wifiGateway = fieldWifiGateway.text
            s.wifiDns = fieldWifiDns.text
        } else {
            s.wifiIpaddr = ""
            s.wifiNetmask = ""
            s.wifiGateway = ""
            s.wifiDns = ""
        }

        wizardContainer.customizationSettings = s
        wizardContainer.userConfigured = !root.useDhcp
    }

    onUseDhcpChanged: commitSettings()
    onNextClicked: commitSettings()
}
