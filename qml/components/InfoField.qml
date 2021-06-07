import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    property alias label: label.text
    property alias value: value.text
    property bool highlight: false  //alias highlighted: value.highlighted
    property alias color: value.color
    property variant fontpixelSize: Theme.fontSizeLarge
    anchors.left: parent.left
    anchors.leftMargin: Theme.paddingMedium
    anchors.right: parent.right
    anchors.rightMargin: Theme.paddingMedium
    height: 40
    Label {
        id: label
        color: Theme.primaryColor
        font.pixelSize: fontpixelSize
        text: "Label"
    }
    Label {
        id: value
        anchors.right: parent.right
        color: highlight ? Theme.secondaryHighlightColor : Theme.secondaryColor
        font.pixelSize: fontpixelSize
        text: "Value"
    }
}
