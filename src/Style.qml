/*
 * SPDX-License-Identifier: Apache-2.0
 * Copyright (C) 2025 Raspberry Pi Ltd
 */

pragma Singleton

import QtQuick
import RpiImager

Item {
    id: root

    // === TEXT SCALING ===
    // Platform text-scaling factor (1.0 = default, 1.5 = 150%, etc.)
    // Reflects OS-level accessibility preferences (Windows "Make text bigger",
    // GNOME text-scaling-factor, etc.) that Qt QML does not honour automatically.
    // DPI normalization is handled by Qt via font.pointSize + screen logical DPI.
    readonly property real textScale: PlatformHelper.textScaleFactor

    // Font-specific scale: DPI correction (72/96 on Windows/Linux, 1.0 on macOS)
    // multiplied by the accessibility text scale. Applied only to font sizes so
    // that layout, spacing, and button sizes are unaffected.
    readonly property real fontScale: PlatformHelper.fontDpiCorrection * textScale

    // Scale a base value by the text scaling factor, rounding to nearest int.
    function scaled(base) { return Math.round(base * textScale) }

    // === COLORS ===
    // UNRAID: values-only rebrand to the Unraid dark theme. The property names and
    // structure are upstream's and must stay that way — see PORTING.md. `raspberryRed`
    // keeps its name (referenced across upstream QML) but carries the Unraid accent.
    readonly property color mainBackgroundColor: "#1C1B1B"
    readonly property color raspberryRed: "#FF8C2F"       // Unraid accent (orange)
    readonly property color transparent: "transparent"

    readonly property color surfaceColor: "#2B2A29"       // UNRAID: elevated dark surface

    readonly property color buttonBackgroundColor: surfaceColor
    readonly property color buttonForegroundColor: raspberryRed
    readonly property color buttonFocusedBackgroundColor: "#3D3B39"
    readonly property color buttonHoveredBackgroundColor: "#383634"

    readonly property color button2BackgroundColor: raspberryRed
    readonly property color button2ForegroundColor: "#1C1B1B"
    // Focused: noticeably darker for strong state indication (keyboard focus)
    readonly property color button2FocusedBackgroundColor: "#C96A1F"
    // Hovered: noticeably lighter to differentiate from base (≥4.5:1 contrast vs base)
    readonly property color button2HoveredBackgroundColor: "#FFA75C"
    // Hovered foreground stays dark for ≥4.5:1 contrast on the light-orange hover bg
    readonly property color button2HoveredForegroundColor: "#1C1B1B"
    readonly property color raspberryRedHighlight: "#FFA75C"

    readonly property color titleBackgroundColor: surfaceColor
    readonly property color titleSeparatorColor: "#3D3B39"
    readonly property color popupBorderColor: "#3D3B39"

    readonly property color listViewRowBackgroundColor: mainBackgroundColor
    readonly property color listViewHoverRowBackgroundColor: titleBackgroundColor
    // Selection highlight color for OS/device lists
    readonly property color listViewHighlightColor: "#4A3A28"

    // Utility translucent colors
    readonly property color translucentWhite10: Qt.rgba(255, 255, 255, 0.1)
    readonly property color translucentWhite30: Qt.rgba(255, 255, 255, 0.3)

    // descriptions in list views
    readonly property color textDescriptionColor: "#E8E6E3"   // UNRAID: light-on-dark
    // Sidebar colors
    readonly property color sidebarActiveBackgroundColor: raspberryRed
    readonly property color sidebarTextOnActiveColor: "#1C1B1B" // UNRAID: dark on orange
    readonly property color sidebarTextOnInactiveColor: "#E8E6E3"
    readonly property color sidebarTextDisabledColor: "#6B6764"
    // Sidebar controls
    readonly property color sidebarControlBorderColor: "#6B6764"
    readonly property color sidebarBackgroundColour: surfaceColor
    readonly property color sidebarBorderColour: "#3D3B39"

    // OS metadata
    readonly property color textMetadataColor: "#A8A4A0"      // UNRAID: light-on-dark

    // for the "device / OS / storage" titles
    readonly property color subtitleColor: "#ffffff"

    readonly property color progressBarTextColor: "#1C1B1B"   // UNRAID: dark on orange bar
    readonly property color progressBarVerifyForegroundColor: "#6cc04a"
    readonly property color progressBarBackgroundColor: raspberryRed
    // New: distinct colors for writing vs verification phases
    readonly property color progressBarWritingForegroundColor: raspberryRed
    readonly property color progressBarTrackColor: "#3D3B39"  // UNRAID: dark track

    readonly property color lanbarBackgroundColor: "#3D3B39"  // UNRAID: dark notice bar

    /// the check-boxes/radio-buttons have labels that might be disabled
    // UNRAID: light-on-dark form text
    readonly property color formLabelColor: "#E8E6E3"
    readonly property color formLabelErrorColor: "#FF6B6B"
    readonly property color formLabelDisabledColor: "#6B6764"
    // Active color for radio buttons, checkboxes, and switches
    readonly property color formControlActiveColor: raspberryRed

    readonly property color embeddedModeInfoTextColor: "#ffffff"

    // Focus/outline
    readonly property color focusOutlineColor: "#0078d4"
    readonly property int focusOutlineWidth: 2
    readonly property int focusOutlineRadius: 4
    readonly property int focusOutlineMargin: -4

    // === FONTS ===
    readonly property alias fontFamily: roboto.name
    readonly property alias fontFamilyLight: robotoLight.name
    readonly property alias fontFamilyBold: robotoBold.name

    // Font sizes (point sizes — DPI-aware, scaled by Qt based on screen logical DPI)
    // Additionally scaled by the OS accessibility text-scaling factor.
    // Base scale (single source of truth)
    readonly property real fontSizeXs: Math.round(12 * fontScale)
    readonly property real fontSizeSm: Math.round(14 * fontScale)
    readonly property real fontSizeMd: Math.round(16 * fontScale)
    readonly property real fontSizeXl: Math.round(24 * fontScale)

    // Role tokens mapped to base scale
    readonly property real fontSizeTitle: fontSizeXl
    readonly property real fontSizeHeading: fontSizeMd
    readonly property real fontSizeLargeHeading: fontSizeMd
    readonly property real fontSizeFormLabel: fontSizeSm
    readonly property real fontSizeSubtitle: fontSizeSm
    readonly property real fontSizeDescription: fontSizeXs
    readonly property real fontSizeInput: fontSizeSm
    readonly property real fontSizeCaption: fontSizeXs
    readonly property real fontSizeSmall: fontSizeXs
    readonly property real fontSizeSidebarItem: fontSizeSm

    // === SPACING (scaled by text scale factor) ===
    readonly property int spacingXXSmall: scaled(2)
    readonly property int spacingXSmall: scaled(5)
    readonly property int spacingTiny: scaled(8)
    readonly property int spacingSmall: scaled(10)
    readonly property int spacingSmallPlus: scaled(12)
    readonly property int spacingMedium: scaled(15)
    readonly property int spacingLarge: scaled(20)
    readonly property int spacingExtraLarge: scaled(30)

    // === SIZES (scaled by text scale factor) ===
    readonly property int buttonHeightStandard: scaled(40)
    readonly property int buttonWidthMinimum: scaled(120)
    readonly property int buttonWidthSkip: scaled(150)

    readonly property int sectionMaxWidth: scaled(500)
    readonly property int sectionMargins: scaled(24)
    readonly property int sectionPadding: scaled(16)
    readonly property int sectionBorderWidth: 1          // not scaled — visual decoration
    readonly property int sectionBorderRadius: 8         // not scaled — visual decoration
    readonly property int listItemBorderRadius: 5        // not scaled — visual decoration
    readonly property int listItemPadding: scaled(15)
    readonly property int cardPadding: scaled(20)
    readonly property int scrollBarWidth: scaled(10)
    readonly property int sidebarWidth: scaled(200)
    readonly property int sidebarMinWidth: scaled(150)
    readonly property int sidebarMaxWidth: scaled(350)
    readonly property int sidebarDragHandleWidth: scaled(8)
    readonly property color sidebarDragHandleHoverColor: listViewHoverRowBackgroundColor
    readonly property color sidebarDragHandleHoverBackground: Qt.rgba(
        listViewHoverRowBackgroundColor.r,
        listViewHoverRowBackgroundColor.g,
        listViewHoverRowBackgroundColor.b, 0.3)
    readonly property int sidebarItemBorderRadius: 4     // not scaled — visual decoration

    // Embedded (kiosk) mode squares off corners (radius 0) to avoid software-renderer
    // antialiasing artifacts. Fixed for the session, so evaluated once.
    readonly property bool embeddedMode: ImageWriterSingleton.isEmbeddedMode()
    // Corner radius to use, given `normalRadius` as the non-embedded value.
    function cornerRadius(normalRadius) { return embeddedMode ? 0 : normalRadius }
    // Sidebar item heights
    readonly property int sidebarItemHeight: buttonHeightStandard
    readonly property int sidebarSubItemHeight: sidebarItemHeight - scaled(12)

    // === LAYOUT (scaled by text scale factor) ===
    readonly property int formColumnSpacing: scaled(20)
    readonly property int formRowSpacing: scaled(15)
    readonly property int stepContentMargins: scaled(24)
    readonly property int stepContentSpacing: scaled(16)

    // Font loaders
    FontLoader { id: roboto;      source: "fonts/Roboto-Regular.ttf" }
    FontLoader { id: robotoLight; source: "fonts/Roboto-Light.ttf" }
    FontLoader { id: robotoBold;  source: "fonts/Roboto-Bold.ttf" }
}
