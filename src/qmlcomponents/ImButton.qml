/*
 * SPDX-License-Identifier: Apache-2.0
 * Copyright (C) 2022 Raspberry Pi Ltd
 */

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2

import RpiImager

Button {

    font.family: Style.fontFamily
    font.bold: true
    background: Rectangle {
        implicitWidth: 100
        implicitHeight: 40
        opacity: enabled ? 1.0 : 0.3
        color: enabled ? (parent.hovered ? Style.unraidAccentColor : Style.unraidPrimaryBgColor) : Style.unraidPrimaryBgColor
        border.color: Style.unraidAccentColor
        border.width: 1
        radius: 25
    }
    contentItem: Text {
        text: parent.text
        font: parent.font
        opacity: enabled ? 1.0 : 0.3
        color: enabled ? (parent.hovered ? Style.unraidTextFocusColor : Style.unraidTextColor) : Style.unraidTextColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
    Accessible.onPressAction: clicked()
    Keys.onEnterPressed: clicked()
    Keys.onReturnPressed: clicked()
}
