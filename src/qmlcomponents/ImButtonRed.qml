/*
 * SPDX-License-Identifier: Apache-2.0
 * Copyright (C) 2022 Raspberry Pi Ltd
 */

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.0
import QtQuick.Controls.Material 2.2

ImButton {
    Material.background: activeFocus ? "#32a0d7" : "#1C1B1B"
    Material.foreground: "#ffffff"
}
