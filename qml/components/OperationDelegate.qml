import QtQuick 2.0
import Sailfish.Silica 1.0

BackgroundItem {

    signal deleteRequested(int operationId)

    property var operationData

    height: Theme.itemSizeLarge

    Row {
        width: parent.width - 2 * Theme.horizontalPageMargin
        anchors.centerIn: parent
        spacing: Theme.paddingMedium

        Image {
            source: operationData.action === 0 ? "image://theme/icon-m-minus" : "image://theme/icon-m-plus"
            width: Theme.iconSizeMedium
            height: width
            anchors.verticalCenter: parent.verticalCenter
        }

        Column {
            width: parent.width - Theme.iconSizeMedium - Theme.paddingMedium
            anchors.verticalCenter: parent.verticalCenter

            Label {
                text: {
                    var category = categoryModel.getCategoryById(operationData.categoryId);
                    return category ? category.nameCategory : "Без категории";
                }
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeSmall
            }

            Label {
                text: Qt.formatDate(new Date(operationData.date), "dd.MM.yyyy")
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
            }
        }

        Label {
            text: (operationData.action === 0 ? "-" : "+") + operationData.amount + " ₽"
            color: operationData.action === 0 ? "red" : "green"
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    ContextMenu {
        MenuItem {
            text: "Удалить"
            onClicked: deleteRequested(operationData.id)
        }
    }
}
