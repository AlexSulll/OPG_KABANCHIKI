import QtQuick 2.0
import Sailfish.Silica 1.0

ListItem {
    id: listItem
    width: parent.width
    contentHeight: Theme.itemSizeMedium

    property var paymentData
    property var categoryModel
    signal deleteRequested(int id)
    property string categoryName: {
        if (!paymentData || !categoryModel)
            return "Без категории";
        var cat = categoryModel.getCategoryById(paymentData.categoryId);
        return cat ? cat.nameCategory : "Без категории";
    }

    Row {
        width: parent.width - 2 * Theme.horizontalPageMargin
        anchors.centerIn: parent
        spacing: Theme.paddingMedium

        Column {
            width: parent.width - deleteBtn.width - Theme.paddingMedium
            spacing: Theme.paddingSmall

            Label {
                text: (paymentData.amount || 0).toFixed(2) + " ₽"
                color: listItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                font.pixelSize: Theme.fontSizeMedium
            }

            Label {
                text: categoryName + " • " + frequencyText
                color: listItem.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
                width: parent.width
                truncationMode: TruncationMode.Fade
            }

            Label {
                text: "Следующий платеж: " + Qt.formatDate(new Date(paymentData.nextPaymentDate || new Date()), "dd.MM.yyyy")
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
            }
        }

        IconButton {
            id: deleteBtn
            icon.source: "image://theme/icon-m-delete"
            onClicked: deleteRequested(paymentData.id)
        }
    }
    property string frequencyText: {
        if (!paymentData)
            return "";
        switch (paymentData.frequency) {
        case 0:
            return "Ежедневно";
        case 1:
            return "Еженедельно";
        case 2:
            return "Каждые 2 недели";
        case 3:
            return "Ежемесячно";
        case 4:
            return "Каждые 2 месяца";
        case 5:
            return "Ежеквартально";
        case 6:
            return "Каждые полгода";
        case 7:
            return "Ежегодно";
        default:
            return "";
        }
    }
}
