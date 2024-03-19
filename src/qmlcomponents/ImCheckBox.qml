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

