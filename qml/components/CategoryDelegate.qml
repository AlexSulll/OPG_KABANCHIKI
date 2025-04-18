import QtQuick 2.0
import Sailfish.Silica 1.0

BackgroundItem {
    property int categoryId: -1
    property string nameCategory: ""
    property string pathToIcon: ""
    property bool isSelected: false
    signal categorySelected(int id)

    width: GridView.view.cellWidth
    height: GridView.view.cellHeight

    Column {
        width: parent.width - Theme.paddingMedium * 2
        anchors.centerIn: parent
        spacing: Theme.paddingSmall

        // Иконка категории
        Rectangle {
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
                onStatusChanged: {
                    if (status === Image.Error) {
                        console.error("Не удалось загрузить иконку:", source);
                    }
                }
            }
        }

        // Название категории
        Label {
            text: nameCategory
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            maximumLineCount: 2
            color: isSelected ? Theme.highlightColor : Theme.primaryColor
        }
    }

    onClicked: categorySelected(categoryId)
}
