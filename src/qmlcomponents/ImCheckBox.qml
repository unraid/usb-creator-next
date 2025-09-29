/*
 * SPDX-License-Identifier: Apache-2.0
 * Copyright (C) 2022 Raspberry Pi Ltd
 */
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import UnraidImager

CheckBox {
    id: control
    activeFocusOnTab: true

    Accessible.role: Accessible.CheckBox
    Accessible.name: text

    Rectangle {
        // This rectangle serves as a high-contrast underline for focus
        anchors.left: control.contentItem.left
        anchors.right: control.contentItem.right
        anchors.top: control.contentItem.bottom
        anchors.topMargin: 2
        height: 2
        color: Style.unraidAccentColor
        visible: control.activeFocus && (control.focusReason === Qt.TabFocusReason || control.focusReason === Qt.BacktabFocusReason)
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

        Image {
            anchors.centerIn: parent
            source: "qrc:/qt/qml/UnraidImager/icons/check.svg"
            // render sharply regardless of DPI/scale
            sourceSize.width: Math.round(parent.width * 0.72)
            sourceSize.height: Math.round(parent.height * 0.72)
            visible: control.checkState === Qt.Checked
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
