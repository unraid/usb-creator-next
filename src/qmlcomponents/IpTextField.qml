import QtQuick 6.0
import QtQuick.Layouts 6.0
import "."

RowLayout {
    property alias label: ipEditLabel.text
    property string fullAddress: fieldIpAddress1.text + "." + fieldIpAddress2.text + "." + fieldIpAddress3.text + "." + fieldIpAddress4.text
    property bool acceptableInput: (fieldIpAddress1.acceptableInput && fieldIpAddress2.acceptableInput && fieldIpAddress3.acceptableInput && fieldIpAddress4.acceptableInput) || !enabled
    property bool enabled: true
    property bool showLabel: true

    TextMetrics {
        id: textMetrics
        font: fieldIpAddress1.font
        text: "255"
    }

    Text {
        id: ipEditLabel
        visible: false
        color: !parent.acceptableInput ? "red" : Style.unraidTextColor
        opacity: parent.enabled ? 1.0 : 0.3
    }

    OctetTextField {
        id: fieldIpAddress1
        enabled: parent.enabled
    }
    Text {
        text: "."
        color: Style.unraidTextColor
        opacity: parent.enabled ? 1.0 : 0.3
    }

    OctetTextField {
        id: fieldIpAddress2
        enabled: parent.enabled
    }
    Text {
        text: "."
        color: Style.unraidTextColor
        opacity: parent.enabled ? 1.0 : 0.3
    }
    OctetTextField {
        id: fieldIpAddress3
        enabled: parent.enabled
    }
    Text {
        text: "."
        color: Style.unraidTextColor
        opacity: parent.enabled ? 1.0 : 0.3
    }
    OctetTextField {
        id: fieldIpAddress4
        enabled: parent.enabled
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
