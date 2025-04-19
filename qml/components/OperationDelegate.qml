import QtQuick 2.0
import Sailfish.Silica 1.0

BackgroundItem {
    property var operationData
    signal deleteRequested(int operationId)

    height: Theme.itemSizeLarge

    Row {
        width: parent.width - 2*Theme.horizontalPageMargin
        anchors.centerIn: parent
        spacing: Theme.paddingMedium

        // Иконка типа операции
        Image {
            source: operationData.action === 0 ?
                "image://theme/icon-m-minus" :
                "image://theme/icon-m-plus"
            width: Theme.iconSizeMedium
            height: width
            anchors.verticalCenter: parent.verticalCenter
        }

        // Основная информация
        Column {
            width: parent.width - Theme.iconSizeMedium - Theme.paddingMedium
            anchors.verticalCenter: parent.verticalCenter

            Label {
                text: operationData.category || "Без категории"
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeSmall
            }

            Label {
                text: Qt.formatDate(new Date(operationData.date), "dd.MM.yyyy")
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
            }
        }

        // Сумма
        Label {
            text: (operationData.action === 0 ? "-" : "+") + operationData.amount + " ₽"
            color: operationData.action === 0 ? "red" : "green"
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // Контекстное меню
    ContextMenu {
        MenuItem {
            text: "Удалить"
            onClicked: deleteRequested(operationData.id)
        }
    }
}
