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

    // indicator: Rectangle {
    //     implicitWidth: 20
    //     implicitHeight: 20
    //     x: control.leftPadding
    //     y: control.height / 2 - height / 2
    //     radius: 3
    //     opacity: control.enabled ? 1.0 : 0.3
    //     color: control.checked ? Style.unraidAccentColor : Style.unraidPrimaryBgColor
    //     border.color: Style.unraidAccentColor

    //     Text {
    //         width: 14
    //         height: 14
    //         x: 3
    //         y: -3
    //         text: "✔"
    //         font.pointSize: 20
    //         color: Style.unraidPrimaryBgColor
    //         visible: control.checked
    //     }
    // }

    // indicator: Rectangle {
    //     implicitWidth: 16
    //     implicitHeight: 16
    //     x: control.leftPadding
    //     y: parent.height / 2 - height / 2
    //     radius: 3

    //     Rectangle {
    //         width: 12
    //         height: 12
    //         x: 2
    //         y: 2
    //         radius: 2
    //         color: Style.unraidAccentColor
    //         visible: control.checked
    //     }
    // }

    // contentItem: Text {
    //     text: control.text
    //     font: control.font
    //     opacity: enabled ? 1.0 : 0.3
    //     color: Style.unraidTextColor
    //     verticalAlignment: Text.AlignVCenter
    //     leftPadding: control.indicator.width + control.spacing
    // }
}
// For Custom Checkbox in Unraid version. Accepted current version -- Ajit
// CheckBox {

//     indicator: Rectangle {
//         implicitWidth: 20
//         implicitHeight: 20
//         x: parent.leftPadding
//         y: parent.height / 2 - height / 2
//         radius: 3
//         opacity: parent.enabled ? 1.0 : 0.3
//         color: parent.checked ? UnColors.orange : UnColors.darkGray
//         border.color: UnColors.orange

//         Text {
//             width: 14
//             height: 14
//             x: 1
//             y: -2
//             text: "✔"
//             font.pointSize: 14
//             color: UnColors.darkGray
//             visible: parent.parent.checked
//         }

//     }

//     contentItem: Text {
//         text: parent.text
//         font: parent.font
//         opacity: parent.enabled ? 1.0 : 0.3
//         color: "white"
//         verticalAlignment: Text.AlignVCenter
//         leftPadding: parent.indicator.width + parent.spacing
//     }

//     Keys.onEnterPressed: toggle()
//     Keys.onReturnPressed: toggle()
// }

