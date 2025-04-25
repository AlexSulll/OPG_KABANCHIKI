import QtQuick 2.0
import Sailfish.Silica 1.0

BackgroundItem {
    id: root
    width: parent.width
    height: Theme.itemSizeSmall

    property string period: ""
    property string selectedPeriod: ""

    signal periodSelected(string period)

    Rectangle {
        anchors.fill: parent
        radius: Theme.paddingSmall
        color: {
            if (root.pressed) return Theme.rgba(Theme.secondaryHighlightColor, 0.2)
            return root.period === root.selectedPeriod
                ? Theme.highlightColor
                : Theme.rgba(Theme.secondaryColor, 0.1)
        }

        border {
            width: 1
            color: root.period === root.selectedPeriod
                ? Theme.highlightColor
                : Theme.rgba(Theme.primaryColor, 0.2)
        }

        Label {
            anchors.centerIn: parent
            text: {
                switch(root.period) {
                    case "day": return "День"
                    case "week": return "Неделя"
                    case "month": return "Месяц"
                    case "year": return "Год"
                    case "custom": return "Период"
                    default: return ""
                }
            }
            color: root.period === root.selectedPeriod
                ? "blue"   // Белый на активной кнопке
                : "red" // Серый на неактивной
            font {
                pixelSize: Theme.fontSizeSmall
                bold: root.period === root.selectedPeriod
            }
        }
    }

    onClicked: periodSelected(period)
}
