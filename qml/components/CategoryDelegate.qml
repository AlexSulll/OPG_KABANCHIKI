import QtQuick 2.0
import Sailfish.Silica 1.0

BackgroundItem {

    signal categorySelected(int id)

    property int categoryId: -1
    property string nameCategory: ""
    property string pathToIcon: ""
    property bool isSelected: false

    width: GridView.view.cellWidth
    height: GridView.view.cellHeight

    Column {
        width: parent.width - Theme.paddingMedium * 2
        anchors.centerIn: parent
        spacing: Theme.paddingSmall

        Rectangle {
            id: iconContainer
            width: parent.width * 0.8
            height: width
            radius: width / 2
            color: isSelected ? Theme.highlightColor : Theme.rgba(Theme.highlightColor, 0.1)

            Image {
                source: pathToIcon
                width: parent.width * 0.6
                height: width
                anchors.centerIn: parent
                sourceSize: Qt.size(width, height)
            }
        }

        Label {
            text: nameCategory
            anchors.horizontalCenter: iconContainer.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            maximumLineCount: 2
            color: isSelected ? Theme.highlightColor : Theme.primaryColor
        }
    }

    onClicked: categorySelected(categoryId)
}
