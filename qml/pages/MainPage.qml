import QtQuick 2.0
import Sailfish.Silica 1.0
import "../services" as Services

Page {
    id: mainPage
    objectName: "mainPage"
    allowedOrientations: Orientation.All

    property var operations: []  // Массив операций для отображения

    PageHeader {
        id: header
        objectName: "pageHeader"
        title: "Расходы"

        extraContent.children: [
            IconButton {
                objectName: "aboutButton"
                icon.source: "image://theme/icon-m-about"
                anchors.verticalCenter: parent.verticalCenter

                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            },
            IconButton {
                objectName: "SecondPage"
                icon.source: "image://theme/icon-m-mail"
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                width: 50
                height: 50
                Rectangle {
                    color: "lightblue"  // Временно делаем фон видимым
                }

                onClicked: {
                    var page = pageStack.push(Qt.resolvedUrl("SecondPage.qml"))
                    if (page && page.operationSaved) {
                        page.operationSaved.connect(function(operation) {
                            operations.push(operation)  // Добавляем операцию в список
                            operationsChanged()  // Обновляем отображение
                        })
                    }
                }
            }

        ]
    }

//    SilicaFlickable {
//        anchors.fill: parent
//        anchors.top: header.bottom
//        contentHeight: list.height + Theme.paddingLarge  // Высота должна корректно подстраиваться

//        ListView {
//            id: list
//            width: parent.width
//            height: operations.length > 0 ? operations.length * Theme.itemSizeLarge : 0 // Динамическая высота в зависимости от количества операций
//            model: operations

//            delegate: ListItem {
//                width: parent.width
//                contentHeight: Theme.itemSizeLarge

//                Column {
//                    anchors.verticalCenter: parent.verticalCenter
//                    spacing: Theme.paddingSmall
//                    width: parent.width - 2 * Theme.horizontalPageMargin
//                    anchors.horizontalCenter: parent.horizontalCenter

//                    Label { text: "Тип: " + operations.type }
//                    Label { text: "Сумма: " + operations.amount }
//                    Label { text: "Дата: " + operations.date }
//                    Label { text: "Комментарий: " + operations.comment }
//                }
//            }
//        }
//    }
}
