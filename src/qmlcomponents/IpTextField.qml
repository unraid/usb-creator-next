import QtQuick 6.0
import QtQuick.Controls 6.0
import QtQuick.Layouts 6.0
import QtQuick.Controls.Material 6.0
import "."

RowLayout {
    property alias label: ipEditLabel.text
    property string fullAddress: fieldIpAddress1.text + "." + fieldIpAddress2.text + "." + fieldIpAddress3.text + "." + fieldIpAddress4.text
    property bool acceptableInput: (fieldIpAddress1.acceptableInput && fieldIpAddress2.acceptableInput && fieldIpAddress3.acceptableInput && fieldIpAddress4.acceptableInput) || !parent.enabled

    TextMetrics {
        id: textMetrics
        font: fieldIpAddress1.font
        text: "255"
    }

    Text {
        id: ipEditLabel
        color: !parent.acceptableInput ? "red" : "white"
        opacity: parent.enabled ? 1.0 : 0.3
    }
    TextField {
        id: fieldIpAddress1
        width: textMetrics.width + leftPadding + rightPadding
        Layout.preferredWidth: textMetrics.width + leftPadding + rightPadding
        horizontalAlignment: TextInput.AlignHCenter
        selectByMouse: true
        validator: IntValidator {
            bottom: 0
            top: 255
        }
    }
    Text {
        text: "."
        color: "white"
        opacity: parent.enabled ? 1.0 : 0.3
    }
    TextField {
        id: fieldIpAddress2
        width: textMetrics.width + leftPadding + rightPadding
        Layout.preferredWidth: textMetrics.width + leftPadding + rightPadding
        horizontalAlignment: TextInput.AlignHCenter
        selectByMouse: true
        validator: IntValidator {
            bottom: 0
            top: 255
        }
    }
    Text {
        text: "."
        color: "white"
        opacity: parent.enabled ? 1.0 : 0.3
    }
    TextField {
        id: fieldIpAddress3
        width: textMetrics.width + leftPadding + rightPadding
        Layout.preferredWidth: textMetrics.width + leftPadding + rightPadding
        horizontalAlignment: TextInput.AlignHCenter
        selectByMouse: true
        validator: IntValidator {
            bottom: 0
            top: 255
        }
    }
    Text {
        text: "."
        color: "white"
        opacity: parent.enabled ? 1.0 : 0.3
    }
    TextField {
        id: fieldIpAddress4
        width: textMetrics.width + leftPadding + rightPadding
        Layout.preferredWidth: textMetrics.width + leftPadding + rightPadding
        horizontalAlignment: TextInput.AlignHCenter
        selectByMouse: true
        validator: IntValidator {
            bottom: 0
            top: 255
        }
    }

    function forceActiveFocus() {
        if (!fieldIpAddress1.acceptableInput) {
            fieldIpAddress1.forceActiveFocus();
        } else if (!fieldIpAddress2.acceptableInput) {
            fieldIpAddress2.forceActiveFocus();
        } else if (!fieldIpAddress3.acceptableInput) {
            fieldIpAddress3.forceActiveFocus();
        } else if (!fieldIpAddress4.acceptableInput) {
            fieldIpAddress4.forceActiveFocus();
        }
    }
}
