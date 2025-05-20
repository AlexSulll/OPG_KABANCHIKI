import QtQuick 2.0
import Sailfish.Silica 1.0
import "../models" as Models
import "../components" as Components

Page {
    id: statsPage
    allowedOrientations: Orientation.All

    Models.OperationModel {
        id: operationModel
        onDataChanged: updateStats()
    }

    property real totalIncome: 0
    property real totalExpense: 0
    property real balance: 0

    Component.onCompleted: {
        operationModel.refresh();
        updateStats();
    }

    onVisibleChanged: {
        operationModel.refresh();
        updateStats();
    }

    Components.HeaderCategoryComponent {
        id: header
        fontSize: Theme.fontSizeExtraLarge * 1.5
        color: "transparent"
        headerText: "Импорт/экспорт"
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
    }

    SilicaFlickable {
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        contentHeight: column.height

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingLarge
            anchors.top: header.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Theme.paddingLarge

            Row {
                width: parent.width
                spacing: Theme.paddingMedium
                Label {
                    text: "Основные показатели"
                    horizontalAlignment: Text.AlignLeft
                    width: parent.width * 0.6
                }
            }

            Row {
                width: parent.width
                spacing: Theme.paddingMedium
                Label {
                    text: "Всего операций"
                    horizontalAlignment: Text.AlignLeft
                    width: parent.width * 0.6
                }
                Label {
                    text: operationModel.count
                    horizontalAlignment: Text.AlignLeft
                    width: parent.width * 0.4
                }
            }

            Row {
                width: parent.width
                spacing: Theme.paddingMedium
                Label {
                    text: "Общий доход"
                    horizontalAlignment: Text.AlignLeft
                    width: parent.width * 0.6
                }
                Label {
                    text: totalIncome.toFixed(2) + " ₽"
                    horizontalAlignment: Text.AlignLeft
                    width: parent.width * 0.4
                }
            }

            Row {
                width: parent.width
                spacing: Theme.paddingMedium
                Label {
                    text: "Общий расход"
                    horizontalAlignment: Text.AlignLeft
                    width: parent.width * 0.6
                }
                Label {
                    text: totalExpense.toFixed(2) + " ₽"
                    horizontalAlignment: Text.AlignLeft
                    width: parent.width * 0.4
                }
            }

            Row {
                width: parent.width
                spacing: Theme.paddingMedium
                Label {
                    text: "Баланс"
                    horizontalAlignment: Text.AlignLeft
                    width: parent.width * 0.6
                }
                Label {
                    text: balance.toFixed(2) + " ₽"
                    horizontalAlignment: Text.AlignLeft
                    width: parent.width * 0.4
                }
            }

            Row {
                width: parent.width
                spacing: Theme.paddingMedium

                Button {
                    width: (parent.width - parent.spacing) / 2
                    text: "Экспорт"
                    onClicked: pageStack.push(Qt.resolvedUrl("ExportPage.qml"))
                }

                Button {
                    width: (parent.width - parent.spacing) / 2
                    text: "Импорт"
                    onClicked: pageStack.push(Qt.resolvedUrl("ImportPage.qml"))
                }
            }
        }
    }

    function updateStats() {
        totalIncome = operationModel.service.getTotalIncome();
        totalExpense = operationModel.service.getTotalExpenses();
        balance = operationModel.calculateTotalBalance();
    }
}
