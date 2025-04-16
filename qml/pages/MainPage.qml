import QtQuick 2.0
import Sailfish.Silica 1.0
import "../services" as Services
import "../models" as Models

Page {
    id: mainPage
    objectName: "mainPage"
    allowedOrientations: Orientation.All

    property var operations: []  // Массив операций для отображения

    PageHeader {
        id: header
        objectName: "pageHeader"
        title: "Расходы"

        Models.OperationModel {
                id: operationModel
        }

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

                onClicked: {
                    var page = pageStack.push(Qt.resolvedUrl("SecondPage.qml"))
                    page.operationModel = operationModel
                    }
                }
        ]
    }
    SilicaFlickable {
        anchors.top: header.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        contentHeight: list.contentHeight + Theme.paddingLarge

        ListView {
            id: list
            anchors.fill: parent
            model: operationModel

            delegate: ListItem {
                width: parent.width
                contentHeight: Theme.itemSizeLarge

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.paddingSmall
                    width: parent.width - 2 * Theme.horizontalPageMargin
                    anchors.horizontalCenter: parent.horizontalCenter

                    Label { text: "Тип: " + (model.action === 0 ? "Расход" : "Доход") }
                    Label { text: "Сумма: " + model.amount }
                    Label { text: "Дата: " + model.date }
                    Label { text: "Комментарий: " + model.desc }
                }
            }


            Label {
                    visible: operationModel.count === 0
                    text: qsTr("Нет операций")
                    anchors.centerIn: parent
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeLarge
            }
        }
    }
}
