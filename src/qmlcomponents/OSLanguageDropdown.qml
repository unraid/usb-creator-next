// qmlcomponents/LanguageDropdown.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.0

Item {
    id: root

    property alias model: combo.model
    property alias currentIndex: combo.currentIndex
    property var window
    property alias font: combo.font
    signal languageChanged(string newLang)

    Layout.fillWidth: true
    Layout.minimumHeight: 40

    ComboBox {
        id: combo
        anchors.fill: parent

        model: root.model
        currentIndex: root.currentIndex

        font.pixelSize: 12
        font.family: roboto.name

        Material.theme: Material.Dark
        Material.foreground: "white"

        //signal
        onActivated: {
            root.languageChanged(combo.editText)
        }

        delegate: ItemDelegate {
            width: combo.width
            height: 40
            property bool isSelected: index === combo.currentIndex

            contentItem: Text {
                text: modelData
                font.pixelSize: 12
                color: isSelected ? UnColors.orange : "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle {
                radius: 25
                color: {
                    if (parent.hovered)
                        return "#424242"
                    return "transparent"
                }
                opacity: {
                    if (isSelected)
                        return 0.6
                    if (parent.hovered)
                        return 1
                    return 1
                }
            }
        }

        background: Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: UnColors.darkGray
            border.color: UnColors.orange
            border.width: 1
        }

        contentItem: Text {
            anchors.fill: parent
            // leftPadding: 12
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: combo.displayText
            font.family: roboto.name
            font.pixelSize: 12
            font.bold: true
            color: "white"
        }
        popup: Popup {
            y: combo.height
            width: combo.width
            property real availableBelow: window.height - combo.mapToItem(
                                              null, 0, combo.height).y
            height: Math.min(contentItem.implicitHeight, availableBelow - 10,
                             200) // 200px max, 10px margin
            // implicitHeight: contentItem.implicitHeight
            padding: 1
            Material.theme: Material.Dark
            Material.accent: UnColors.mediumGray

            contentItem: ListView {
                clip: true
                width: combo.width
                implicitHeight: contentHeight
                model: combo.popup.visible ? combo.delegateModel : null
                currentIndex: combo.highlightedIndex
                ScrollIndicator.vertical: ScrollIndicator {}
            }
            background: Rectangle {
                color: UnColors.darkGray
            }
        }
    }
}
