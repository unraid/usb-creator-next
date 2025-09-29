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
        onTextChanged:{
            if (acceptableInput && text.length === maximumLength) {
                fieldIpAddress2.forceActiveFocus();
            }
        }
    }
    Text {
        text: "."
        color: Style.unraidTextColor
        opacity: parent.enabled ? 1.0 : 0.3
    }

    OctetTextField {
        id: fieldIpAddress2
        enabled: parent.enabled
        onTextChanged:{
            if (acceptableInput && text.length === maximumLength) {
                fieldIpAddress3.forceActiveFocus();
            }
        }
    }
    Text {
        text: "."
        color: Style.unraidTextColor
        opacity: parent.enabled ? 1.0 : 0.3
    }
    OctetTextField {
        id: fieldIpAddress3
        enabled: parent.enabled
        onTextChanged:{
            if (acceptableInput && text.length === maximumLength) {
                fieldIpAddress4.forceActiveFocus();
            }
        }
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

   
}
