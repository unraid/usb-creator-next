/*
 * SPDX-License-Identifier: Apache-2.0
 * Copyright (C) 2021 Raspberry Pi Ltd
 */

pragma ComponentBehavior: Bound

import QtQuick 2.15
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.2
import QtQuick.Window 2.15

import RpiImager

MainPopupBase {
    id: root

    // Provide implementation for the base popup's navigation functions
    function getNextFocusableElement(startElement) {
        var focusableItems = [dstlist, filterSystemDrives, root.closeButton].filter(function (item) {
            return item.visible && item.enabled;
        });

        if (focusableItems.length === 0)
            return startElement;

        var currentIndex = focusableItems.indexOf(startElement);
        if (currentIndex === -1)
            return focusableItems[0];

        var nextIndex = (currentIndex + 1) % focusableItems.length;
        return focusableItems[nextIndex];
    }

    function getPreviousFocusableElement(startElement) {
        var focusableItems = [dstlist, filterSystemDrives, root.closeButton].filter(function (item) {
            return item.visible && item.enabled;
        });

        if (focusableItems.length === 0)
            return startElement;

        var currentIndex = focusableItems.indexOf(startElement);
        if (currentIndex === -1)
            return focusableItems[focusableItems.length - 1];

        var prevIndex = (currentIndex - 1 + focusableItems.length) % focusableItems.length;
        return focusableItems[prevIndex];
    }

    required property ImageWriter imageWriter
    property alias dstlist: dstlist

    onClosed: imageWriter.stopDriveListPolling()

    title: qsTr("Storage")

    MainPopupListViewBase {
        id: dstlist
        model: root.imageWriter.getDriveList()
        delegate: dstdelegate
        anchors.top: root.title_separator.bottom
        anchors.right: parent.right

        onActiveFocusChanged: {
            if (activeFocus && currentIndex === -1 && count > 0) {
                currentIndex = 0;
            }
        }

        Label {
            anchors.fill: parent
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            visible: {
                var visibleCount = 0;
                for (var i = 0; i < dstlist.count; i++) {
                    var item = dstlist.itemAtIndex(i);
                    if (item && item.visible) {
                        visibleCount++;
                    }
                }
                return visibleCount === 0;
            }
            color: Style.unraidTextColor
            text: qsTr("No storage devices found")
            font.bold: true
        }

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Backtab || (event.key === Qt.Key_Tab && event.modifiers & Qt.ShiftModifier)) {
                root.getPreviousFocusableElement(dstlist).forceActiveFocus();
                event.accepted = true;
            } else if (event.key === Qt.Key_Tab) {
                root.getNextFocusableElement(dstlist).forceActiveFocus();
                event.accepted = true;
            } else {
                // Allow default up/down arrow processing
                event.accepted = false;
            }
        }

        Keys.onSpacePressed: {
            if (currentIndex == -1)
                return;
            root.selectDstItem(currentItem);
        }
        Accessible.onPressAction: {
            if (currentIndex == -1)
                return;
            root.selectDstItem(currentItem);
        }
    }

    RowLayout {
        id: filterRow
        anchors {
            bottom: parent.bottom
            right: parent.right
            left: parent.left
        }
        Item {
            Layout.fillWidth: true
        }
        ImCheckBox {
            id: filterSystemDrives
            checked: true
            text: qsTr("Exclude System Drives")

            Keys.onPressed: event => {
                if (event.key === Qt.Key_Backtab || (event.key === Qt.Key_Tab && event.modifiers & Qt.ShiftModifier)) {
                    root.getPreviousFocusableElement(filterSystemDrives).forceActiveFocus();
                    event.accepted = true;
                } else if (event.key === Qt.Key_Tab) {
                    root.getNextFocusableElement(filterSystemDrives).forceActiveFocus();
                    event.accepted = true;
                }
            }
        }
    }

    Component {
        id: dstdelegate

        Item {
            id: dstitem

            required property int index
            required property string device
            required property string description
            required property string size
            required property bool isUsb
            required property bool isScsi
            required property bool isReadOnly
            required property bool isSystem
            required property var mountpoints
            required property QtObject modelData
            required property string guid
            required property bool guidValid

            readonly property bool shouldHide: isSystem && filterSystemDrives.checked
            readonly property bool unselectable: isReadOnly

            enabled: !unselectable
            property bool hovered: false

            anchors.left: parent ? parent.left : undefined
            anchors.right: parent ? parent.right : undefined
            height: shouldHide ? 0 : 81
            visible: !shouldHide

            Accessible.name: {
                var text = [];

                var sizeStr = (dstitem.size / 1000000000).toFixed(1) + " " + qsTr("GB");
                text.push(dstitem.description + ", " + sizeStr);

                if (dstitem.mountpoints && dstitem.mountpoints.length > 0) {
                    text.push(qsTr("Mounted as %1").arg(dstitem.mountpoints.join(", ")));
                }

                if (dstitem.isReadOnly) {
                    text.push(qsTr("Write protected"));
                } else if (dstitem.isSystem) {
                    text.push(qsTr("System drive"));
                }

                if (dstitem.guid && dstitem.guid !== "") {
                    if (dstitem.guidValid) {
                        text.push(qsTr("GUID: %1").arg(dstitem.guid));
                    } else {
                        text.push(qsTr("GUID invalid"));
                    }
                }

                if (!dstitem.guidValid) {
                    text.push(qsTr("Cannot be selected"));
                }

                return text.join(", ");
            }

            Rectangle {
                id: dstbgrect
                anchors.fill: parent
                anchors.top: parent ? parent.top : undefined
                anchors.left: parent ? parent.left : undefined
                anchors.right: parent ? parent.right : undefined
                height: parent.height
                color: dstitem.hovered ? Style.unraidAccentColor : Style.unraidPrimaryBgColor
                border.color: Style.unraidSecondaryBgColor
            }

            HoverHandler {
                target: dstitem
                cursorShape: !dstitem.unselectable ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                enabled: !dstitem.unselectable
                onHoveredChanged: {
                    dstitem.hovered = hovered;
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: false
                cursorShape: Qt.PointingHandCursor
                onClicked: root.selectDstItem(dstitem.modelData)
            }

            RowLayout {
                anchors.fill: parent
                Item {
                    Layout.preferredWidth: 25
                }

                Image {
                    id: dstitem_image
                    source: dstitem.isUsb ? (dstitem.hovered ? "icons/ic_usb_40px.svg" : "icons/ic_usb_40px_orange.svg") : dstitem.isScsi ? (dstitem.hovered ? "icons/ic_storage_40px.svg" : "icons/ic_storage_40px_orange.svg") : (dstitem.hovered ? "icons/ic_sd_storage_40px.svg" : "icons/ic_sd_storage_40px_orange.svg")
                    verticalAlignment: Image.AlignVCenter
                    fillMode: Image.Pad
                    opacity: enabled ? 1.0 : 0.3
                }

                Item {
                    Layout.preferredWidth: 25
                }

                ColumnLayout {

                    Text {
                        textFormat: Text.StyledText
                        verticalAlignment: Text.AlignVCenter
                        Layout.fillWidth: true
                        font.family: Style.fontFamily
                        font.pointSize: 16
                        color: dstitem.hovered ? Style.unraidPrimaryBgColor : Style.unraidTextColor
                        opacity: enabled ? 1.0 : 0.3
                        text: {
                            var sizeStr = (dstitem.size / 1000000000).toFixed(1) + " " + qsTr("GB");
                            return dstitem.description + " - " + sizeStr;
                        }
                    }

                    Text {
                        textFormat: Text.StyledText
                        verticalAlignment: Text.AlignVCenter
                        Layout.fillWidth: true
                        font.family: Style.fontFamily
                        font.pointSize: 12
                        color: dstitem.hovered ? Style.unraidPrimaryBgColor : Style.unraidTextColor
                        opacity: enabled ? 1.0 : 0.3
                        text: {
                            var txt = qsTr("Mounted as %1").arg(dstitem.mountpoints.join(", "));
                            if (dstitem.isReadOnly) {
                                txt += " " + qsTr("[WRITE PROTECTED]");
                            } else if (dstitem.isSystem) {
                                txt += " [" + qsTr("SYSTEM") + "]";
                            }
                            return txt;
                        }
                    }
                    RowLayout {
                        spacing: 4
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter

                        Text {
                            textFormat: Text.StyledText

                            verticalAlignment: Text.AlignVCenter
                            font.family: Style.fontFamily
                            font.pointSize: 12
                            color: dstitem.hovered ? Style.unraidPrimaryBgColor : Style.unraidTextColor
                            opacity: enabled ? 1.0 : 0.3
                            text: {
                                var txt = "";
                                if (dstitem.guid != "") {
                                    dstitem.guidValid ? txt += "GUID: %1".arg(dstitem.guid) : txt += "GUID: %1 <font color='red'>[BLACKLISTED]</font>".arg(dstitem.guid);
                                } else {
                                    txt += "<font color='red'>[MISSING GUID - Choose Another Flash Device]</font>";
                                }

                                return txt;
                            }
                        }
                        ToolButton {
                            id: toolButton
                            icon.source: dstitem.hovered ? "unraid/icons/info_dark_gray.svg" : "unraid/icons/info_orange.svg"
                            icon.color: "transparent"
                            icon.width: 16
                            icon.height: 16
                            Layout.alignment: Qt.AlignVCenter
                            padding: 0
                            implicitWidth: icon.width
                            implicitHeight: icon.height
                            visible: dstitem.guid != "" && !dstitem.guidValid
                            hoverEnabled: true
                            ToolTip.visible: hovered
                            ToolTip.text: "This USB device is blacklisted. You may not be able to use this device to get an Unraid license or trial."
                        }
                    }
                }
            }

            Rectangle {
                id: dstborderrect
                anchors.top: dstbgrect.bottom
                anchors.left: parent ? parent.left : undefined
                anchors.right: parent ? parent.right : undefined
                height: 1
                color: Style.unraidSecondaryBgColor
            }

            // MouseArea {
            //     anchors.fill: parent
            //     cursorShape: !dstitem.unselectable ? Qt.PointingHandCursor : Qt.ForbiddenCursor
            //     hoverEnabled: true
            //     enabled: !dstitem.unselectable

            //     onEntered: {
            //         dstbgrect.mouseOver = true;
            //     }

            //     onExited: {
            //         dstbgrect.mouseOver = false;
            //     }

            //     onClicked: {
            //         root.selectDstItem(dstitem.modelData);
            //     }
            // }
        }
    }

    function selectDstItem(d) {
        if (d.isReadOnly) {
            onError(qsTr("SD card is write protected.<br>Push the lock switch on the left side of the card upwards, and try again."));
            return;
        }

        imageWriter.setDst(d.device, d.guidValid);
        window.selectedStorageName = d.description;
        if (imageWriter.readyToWrite()) {
            writebutton.enabled = true;
        }
        root.close();
    }

    onOpened: {
        root.contentItem.forceActiveFocus();
    }
}
