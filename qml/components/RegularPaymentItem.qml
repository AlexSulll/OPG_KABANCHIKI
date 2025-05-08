import QtQuick 2.0
import Sailfish.Silica 1.0

ListItem {
    id: listItem
    width: parent.width
    contentHeight: Theme.itemSizeMedium

    property var paymentData
    signal deleteRequested(int id)

    Row {
        width: parent.width - 2*Theme.horizontalPageMargin
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
                text: (paymentData.categoryName || "Без категории") + " • " + getFrequencyText(paymentData.frequency || 0)
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

    function getFrequencyText(frequency) {
        switch(frequency) {
            case 0: return "Ежемесячно";
            case 1: return "Ежеквартально";
            case 2: return "Ежегодно";
            default: return "";
        }
    }
}
