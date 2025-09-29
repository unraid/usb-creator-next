/*
 * SPDX-License-Identifier: Apache-2.0
 * Copyright (C) 2022 Raspberry Pi Ltd
 */

import QtQuick.Controls.Material 2.2

import UnraidImager

ImButton {
    Material.background: activeFocus ? Style.button2FocusedBackgroundColor : Style.mainBackgroundColor
    Material.foreground: Style.button2ForegroundColor
}
