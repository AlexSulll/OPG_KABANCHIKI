import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    id: cover

    Column {
        anchors.centerIn: parent
        spacing: Theme.paddingLarge

        Image {
            source: Qt.resolvedUrl("../icons/WebBudget.svg")
            width: Theme.iconSizeLauncher
            height: Theme.iconSizeLauncher
            anchors.horizontalCenter: parent.horizontalCenter
            fillMode: Image.PreserveAspectFit
        }

        Label {
            text: qsTr("WebBudget")
            font.pixelSize: Theme.fontSizeLarge
            color: Theme.primaryColor
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
