import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: dialog
    allowedOrientations: Orientation.All

    property string fileName
    property int dataSize
    property int operationsCount
    property string sampleData
    property string filePath

    Column {
        width: parent.width
        spacing: Theme.paddingLarge

        DialogHeader {
            title: "Экспорт завершен"
            acceptText: "OK"
        }

        Label {
            x: Theme.horizontalPageMargin
            width: parent.width - 2*x
            wrapMode: Text.Wrap
            color: Theme.highlightColor
            text: "Файл: " + fileName
        }

        Label {
            x: Theme.horizontalPageMargin
            width: parent.width - 2*x
            wrapMode: Text.Wrap
            color: Theme.highlightColor
            text: "Операций экспортировано: " + operationsCount
        }

        Label {
            x: Theme.horizontalPageMargin
            width: parent.width - 2*x
            wrapMode: Text.Wrap
            color: Theme.highlightColor
            text: "Размер данных: " + dataSize + " байт"
        }

        SectionHeader {
            text: "Пример данных:"
        }

        TextArea {
            width: parent.width
            height: Math.min(implicitHeight, Screen.height/3)
            readOnly: true
            text: sampleData
            font.pixelSize: Theme.fontSizeExtraSmall
            color: Theme.secondaryColor
        }
    }
}
