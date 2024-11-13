/*
 * SPDX-License-Identifier: Apache-2.0
 * Copyright (C) 2022 Raspberry Pi Ltd
 */

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import RpiImager

CheckBox {
    id: control
    activeFocusOnTab: true

    Rectangle {
        // This rectangle serves as a high-contrast underline for focus
        anchors.left: control.contentItem.left
        anchors.right: control.contentItem.right
        anchors.top: control.contentItem.bottom
        anchors.topMargin: 2
        height: 2
        color: Style.unraidAccentColor
        visible: control.activeFocus
    }

    // Accessibility improvements
    Accessible.role: Accessible.CheckBox
    Accessible.name: text
    Accessible.description: checked ? "checked" : "unchecked"

    Rectangle {
        anchors.left: control.contentItem.left
        anchors.right: control.contentItem.right
        anchors.top: control.contentItem.bottom
        anchors.topMargin: 2
        height: 2
        color: Style.unraidAccentColor
        visible: control.activeFocus
    }

    indicator: Rectangle {
        implicitWidth: 20
        implicitHeight: 20
        x: control.leftPadding
        y: control.height / 2 - height / 2
        radius: 3
        opacity: control.enabled ? 1.0 : 0.3
        color: control.checked ? Style.unraidAccentColor : Style.unraidPrimaryBgColor
        border.color: Style.unraidAccentColor

        // Smooth transitions
        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }
        Behavior on border.color {
            ColorAnimation {
                duration: 150
            }
        }

        Text {
            anchors.centerIn: parent
            text: "✔"
            font.pointSize: 18
            color: Style.unraidPrimaryBgColor
            visible: control.checked
            opacity: control.checked ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                }
            }
        }
    }

    contentItem: Text {
        text: control.text
        font: control.font
        opacity: enabled ? 1.0 : 0.3
        color: control.hovered ? Qt.lighter(Style.unraidTextColor, 1.1) : Style.unraidTextColor
        verticalAlignment: Text.AlignVCenter
        leftPadding: control.indicator.width + control.spacing

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }
    }
}
