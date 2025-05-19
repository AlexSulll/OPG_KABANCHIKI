import QtQuick 2.0
import Sailfish.Silica 1.0

Rectangle {
    id: headerRoot

    width: parent.width
    height: parent.height / 10
    color: "#24224f"

    property string headerText: ""
    property int fontSize: Theme.fontSizeExtraLarge * 2
    property bool showIcon: true

    Row {
        id: balanceRow1
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            topMargin: Theme.paddingMedium
        }
        spacing: Theme.paddingMedium

        Image {
            source: "../icons/WebBudget.svg"
            height: Theme.iconSizeLarge
            width: Theme.iconSizeLarge
            visible: headerRoot.showIcon
        }

        Label {
            text: headerRoot.headerText
            color: Theme.highlightColor
            font.pixelSize: headerRoot.fontSize
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
