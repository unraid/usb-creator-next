import QtQuick 6.0
import QtQuick.Controls 6.0
import QtQuick.Layouts 6.0
import QtQuick.Controls.Material 6.0

TextField {
    id: octetField

    property int maxValue: 255
    property int minValue: 0

    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0
    leftInset: 0
    rightInset: 0
    topInset: 0
    bottomInset: 0

    Layout.preferredWidth: textMetrics.width + 15
    Layout.preferredHeight: textMetrics.width
    horizontalAlignment: TextInput.AlignHCenter
    selectByMouse: true
    maximumLength: 3

    validator: IntValidator {
        bottom: octetField.minValue
        top: octetField.maxValue
    }

    Material.containerStyle: Material.Filled

    TextMetrics {
        id: textMetrics
        font: octetField.font
        text: "255"
    }


    // Custom background with underline
    background: Rectangle {
        color: "transparent"
        implicitHeight: 40

        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            height: 1
            opacity: octetField.enabled ? 1.0 : 0.3
            color: octetField.enabled
                   ? (octetField.focus ? Style.unraidAccentColor
                      : (octetField.hovered ? "#ffffff" : "#bdbdbd"))
                   : "#bdbdbd"
        }
    }


}
