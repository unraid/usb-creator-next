/*
 * SPDX-License-Identifier: Apache-2.0
 * Copyright (C) 2020 Raspberry Pi Ltd
 */

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.0
import QtQuick.Controls.Material 2.2
import "qmlcomponents"

Popup {
    id: popup
    x: 50
    y: 25
    width: parent.width-100
    height: parent.height-50
    padding: 0
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    
    Material.theme: Material.Dark
    Material.background: UnColors.darkGray
    Material.accent: UnColors.orange
    
    property bool initialized: false
    property bool hasSavedSettings: false
    property string config
    property string cmdline
    property string firstrun
    property string cloudinit
    property string cloudinitrun
    property string cloudinitwrite
    property string cloudinitnetwork
    property bool validInputs: false

    signal saveSettingsSignal(var settings)
    signal continueSignal()
    
    background: Rectangle {
        color: UnColors.darkGray
        border.color: UnColors.mediumGray
    }

    // background of title
    Rectangle {
        color: UnColors.mediumGray
        anchors.right: parent.right
        anchors.top: parent.top
        height: 35
        width: parent.width
    }
    // line under title
    Rectangle {
        color: UnColors.mediumGray
        width: parent.width
        y: 35
        implicitHeight: 1
    }

    Text {
        color: "white"
        text: "X"
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 25
        anchors.topMargin: 10
        font.family: roboto.name
        font.bold: true

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                popup.close()
            }
        }
    }

    ColumnLayout {
        spacing: 10
        width: parent.width
        Text {
            color: "white"
            text: qsTr("Settings")
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            Layout.fillWidth: true
            Layout.topMargin: 10
            font.family: roboto.name
            font.bold: true
        }
        GroupBox {

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: 25
            Layout.rightMargin: 25
            Layout.topMargin: 10
            ColumnLayout {
                // General tab
                spacing: -10

                RowLayout {
                    Text {
                        text : "Server Name:"
                        color: !fieldServername.acceptableInput ? "red" : "white"
                    }
                    TextField {
                        id: fieldServername
                        text: "Tower"
                        horizontalAlignment: TextInput.AlignHCenter
                        selectByMouse: true
                        maximumLength: 15
                        validator: RegExpValidator { regExp: /^[A-Za-z0-9]([A-Za-z0-9\-\.]{0,13}[A-Za-z0-9])?$/ }
                    }
                }
                
                RowLayout {
                    Text {
                        text : "Network Mode:"
                        color: "white"
                    }
                    ImRadioButton {
                        id: radioDhcp
                        text: qsTr("DHCP")
                        checked: true
                        onCheckedChanged: {
                        }
                    }
                    ImRadioButton {
                        id: radioStaticIp
                        text: qsTr("Static IP")
                        onCheckedChanged: {
                        }
                    }
                }
                
                RowLayout {
                    enabled: radioStaticIp.checked
                    IpTextField {
                        id: ipAddressField
                        label : "IP Address:"
                    }
                    Text {
                        text : "Netmask:"
                        color: "white"
                        opacity: parent.enabled ? 1.0 : 0.3
                    }
                    ComboBox {
                        id: fieldNetmask
                        font.family: roboto.name
                        model: ["255.255.0.0",
                                "255.255.128.0",
                                "255.255.192.0",
                                "255.255.224.0",
                                "255.255.240.0",
                                "255.255.248.0",
                                "255.255.252.0",
                                "255.255.254.0",
                                "255.255.255.0",
                                "255.255.255.128",
                                "255.255.255.192",
                                "255.255.255.224",
                                "255.255.255.240",
                                "255.255.255.248",
                                "255.255.255.252"]
                        Layout.preferredWidth: 200
                        currentIndex: -1
                        Component.onCompleted: {
                            currentIndex = find("255.255.255.0")
                        }
                        Layout.topMargin: 10
                        Layout.bottomMargin: 10
                        popup: Popup {
                            y: fieldNetmask.height - 1
                            width: fieldNetmask.width
                            implicitHeight: contentItem.implicitHeight
                            padding: 1
                            Material.theme: Material.Dark
                            Material.accent: UnColors.orange

                            contentItem: ListView {
                                clip: true
                                implicitHeight: contentHeight
                                model: fieldNetmask.delegateModel
                                currentIndex: fieldNetmask.highlightedIndex

                                ScrollIndicator.vertical: ScrollIndicator { }
                            }

                            background: Rectangle {
                                color: UnColors.darkGray
                                radius: 2
                            }
                        }
                    }
                }
                RowLayout {
                    enabled: radioStaticIp.checked
                    IpTextField {
                        id: gatewayField
                        label : "Gateway:"
                    }
                    IpTextField {
                        id: dnsField
                        label : "DNS Server:"
                    }
                }
            }
            
        }
        RowLayout {
            Layout.alignment: Qt.AlignCenter | Qt.AlignBottom
            Layout.bottomMargin: 10
            spacing: 20

            ImButton {
                text: qsTr("CONTINUE")
                onClicked: {
                    checkInputs()
                    if(validInputs) {
                        applySettings()
                        popup.close()
                        continueSignal()
                    }
                }
            }

            Text { text: " " }
        }

    }


    function openPopup() {
        if (!initialized) {
            initialize()
            if (imageWriter.hasSavedCustomizationSettings())
            {
                applySettings()
            }
        }

        open()
    }
    
    function initialize() {
        initialized = true
    }
    
    function checkInputs() {
        validInputs = false
        if (!fieldServername.acceptableInput) {
            fieldServername.forceActiveFocus()
            return
        }
        if (!ipAddressField.acceptableInput) {
            ipAddressField.forceActiveFocus()
            return
        }
        if (!gatewayField.acceptableInput) {
            gatewayField.forceActiveFocus()
            return
        }
        if (!dnsField.acceptableInput) {
            dnsField.forceActiveFocus()
            return
        }
        validInputs = true
    }
    
    function applySettings() {
        var settings = { };
        settings.dhcp = radioDhcp.checked
        settings.static = radioStaticIp.checked
        settings.ipaddr = ipAddressField.fullAddress
        settings.gateway = gatewayField.fullAddress
        settings.dns = dnsField.fullAddress
        settings.netmask = fieldNetmask.currentText
        settings.servername = fieldServername.text
        imageWriter.setSavedCustomizationSettings(settings)
        
        
        // default these to off for now
        imageWriter.setSetting("beep", false)
        imageWriter.setSetting("eject", false)
        imageWriter.setSetting("telemetry", false) // chkTelemtry.checked)
        
        cmdline = ""
        config = ""
        firstrun = ""
        cloudinit = ""
        cloudinitrun = ""
        cloudinitwrite = ""
        cloudinitnetwork = ""
        imageWriter.setImageCustomization(config, cmdline, firstrun, cloudinit, cloudinitnetwork)
    }
}
