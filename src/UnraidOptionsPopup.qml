/*
 * SPDX-License-Identifier: Apache-2.0
 * Copyright (C) 2020 Raspberry Pi Ltd
 */
import QtQuick 6.0
import QtQuick.Controls 6.0
import QtQuick.Layouts 6.0
import QtQuick.Controls.Material 6.0
import "qmlcomponents"

Popup {
    id: popup
    x: 50
    y: 25
    width: parent.width - 100
    height: parent.height - 50
    padding: 0
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    Material.theme: Material.Dark
    Material.background: Style.unraidPrimaryBgColor
    Material.accent: Style.unraidAccentColor

    required property ImageWriter imageWriter
    property bool initialized: false
    property bool hasSavedSettings: false
    property bool validInputs: false

    signal saveSettingsSignal(var settings)
    signal continueSignal

    background: Rectangle {
        color: Style.unraidPrimaryBgColor
        border.color: Style.unraidSecondaryBgColor
    }

    // background of title
    Rectangle {
        color: Style.unraidSecondaryBgColor
        anchors.right: parent.right
        anchors.top: parent.top
        height: 35
        width: parent.width
    }
    // line under title
    Rectangle {
        color: Style.unraidSecondaryBgColor
        width: parent.width
        y: 35
        implicitHeight: 1
    }

    Text {
        color: Style.unraidTextColor
        text: "X"
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 25
        anchors.topMargin: 10
        font.family: Style.fontFamily
        font.bold: true

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                popup.close();
            }
        }
    }

    ColumnLayout {
        width: parent.width
        spacing: 10
        Text {
            color: Style.unraidTextColor
            text: qsTr("Settings")
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            Layout.fillWidth: true
            Layout.topMargin: 10
            font.family: Style.fontFamily
            font.bold: true
        }

        GroupBox {
            Layout.fillWidth: true
            Layout.leftMargin: 25
            Layout.rightMargin: 25
            Layout.topMargin: 10

            GridLayout {
                id: formGrid
                columns: 2
                columnSpacing: 16
                rowSpacing: 15
                Layout.topMargin: 5

                // Server Name
                Text {
                    text: "Server Name:"
                    color: !fieldServername.acceptableInput ? "red" : Style.unraidTextColor
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                }
                TextField {
                    id: fieldServername
                    text: "Tower"
                    horizontalAlignment: TextInput.AlignLeft
                    selectByMouse: true
                    maximumLength: 15
                    validator: RegularExpressionValidator {
                        regularExpression: /^[A-Za-z0-9]([A-Za-z0-9\-\.]{0,13}[A-Za-z0-9])?$/
                    }
                    Layout.fillWidth: true
                }

                // Network Mode
                Text {
                    text: "Network Mode:"
                    color: Style.unraidTextColor
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                }
                RowLayout {
                    ImRadioButton {
                        id: radioDhcp
                        text: qsTr("DHCP")
                        checked: true
                        onCheckedChanged: {}
                    }
                    ImRadioButton {
                        id: radioStaticIp
                        text: qsTr("Static IP")
                        onCheckedChanged: {}
                    }
                }

                // IP Address
                Text {
                    text: "IP Address:"
                    color: !ipAddressField.acceptableInput ? "red" : Style.unraidTextColor
                    opacity: radioStaticIp.checked ? 1.0 : 0.3
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                }
                IpTextField {
                    id: ipAddressField
                    showLabel: false
                    enabled: radioStaticIp.checked
                    Layout.fillWidth: true
                }

                // Netmask
                Text {
                    text: "Netmask:"
                    color: Style.unraidTextColor
                    opacity: radioStaticIp.checked ? 1.0 : 0.3
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    Layout.topMargin: 5
                }
                ComboBox {
                    id: fieldNetmask
                    enabled: radioStaticIp.checked
                    font.family: Style.fontFamily
                    model: ["255.255.0.0", "255.255.128.0", "255.255.192.0", "255.255.224.0", "255.255.240.0", "255.255.248.0", "255.255.252.0", "255.255.254.0", "255.255.255.0", "255.255.255.128", "255.255.255.192", "255.255.255.224", "255.255.255.240", "255.255.255.248", "255.255.255.252"]
                    Layout.preferredWidth: 200
                    currentIndex: -1
                    Component.onCompleted: currentIndex = find("255.255.255.0")
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    Layout.fillWidth: true
                    Layout.topMargin: 5

                    popup: Popup {
                        y: fieldNetmask.height
                        width: fieldNetmask.width
                        implicitHeight: contentItem.implicitHeight

                        padding: 1
                        Material.theme: Material.Dark
                        Material.accent: Style.unraidAccentColor

                        contentItem: ListView {
                            clip: true
                            implicitHeight: contentHeight
                            model: fieldNetmask.delegateModel
                            currentIndex: fieldNetmask.highlightedIndex

                            ScrollIndicator.vertical: ScrollIndicator {}
                        }

                        background: Rectangle {
                            color: Style.unraidPrimaryBgColor
                            radius: 2
                        }
                    }
                }

                // Gateway
                Text {
                    text: "Gateway:"
                    color: !gatewayField.acceptableInput ? "red" : Style.unraidTextColor
                    opacity: radioStaticIp.checked ? 1.0 : 0.3
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                }
                IpTextField {
                    id: gatewayField
                    showLabel: false
                    enabled: radioStaticIp.checked
                    Layout.fillWidth: true
                }

                // DNS Server
                Text {
                    text: "DNS Server:"
                    color: !dnsField.acceptableInput ? "red" : Style.unraidTextColor
                    opacity: radioStaticIp.checked ? 1.0 : 0.3
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                }
                IpTextField {
                    id: dnsField
                    showLabel: false
                    enabled: radioStaticIp.checked
                    Layout.fillWidth: true
                    Layout.bottomMargin: 10
                }
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignCenter | Qt.AlignBottom
            spacing: 10

//  This part needs to be refactored to make validInputs a live binding instead.
            ImButton {
                enabled: {
                    popup.checkInputs();
                    return popup.validInputs;
                    }
                text: qsTr("CONTINUE")
                onClicked: {
                    popup.checkInputs();
                    if (popup.validInputs) {
                        popup.applySettings();
                        popup.close();
                        popup.continueSignal();
                    }
                }
            }
        }
    }

    function openPopup() {
        if (!initialized) {
            initialize();
            if (imageWriter.hasSavedCustomizationSettings()) {
                applySettings();
            }
        }

        open();
    }

    function initialize() {
        initialized = true;
    }

    function checkInputs() {
        validInputs = false;
        if (!fieldServername.acceptableInput) {
            fieldServername.forceActiveFocus();
            return;
        }
        if (!ipAddressField.acceptableInput) {
            ipAddressField.forceActiveFocus();
            return;
        }
        if (!gatewayField.acceptableInput) {
            gatewayField.forceActiveFocus();
            return;
        }
        if (!dnsField.acceptableInput) {
            dnsField.forceActiveFocus();
            return;
        }
        validInputs = true;
    }

    function applySettings() {
        var settings = {};
        settings.dhcp = radioDhcp.checked;
        settings.static = radioStaticIp.checked;
        settings.ipaddr = ipAddressField.fullAddress;
        settings.gateway = gatewayField.fullAddress;
        settings.dns = dnsField.fullAddress;
        settings.netmask = fieldNetmask.currentText;
        settings.servername = fieldServername.text;

        saveSettingsSignal(settings);
    }
}
