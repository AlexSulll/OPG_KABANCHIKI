import QtQuick 2.0
import Sailfish.Silica 1.0

ListItem {
    id: delegate
    width: parent.width
    contentHeight: Theme.itemSizeLarge * 1.5

    property real monthlyPayment: calculateMonthlyPayment()

    function calculateMonthlyPayment() {
        const remaining = targetAmount - currentAmount
        const monthsLeft = Math.ceil((new Date(endDate) - new Date()) / (1000*60*60*24*30))
        return monthsLeft > 0 ? (remaining / monthsLeft).toFixed(2) : 0
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.rgba(Theme.highlightColor, 0.1)
        radius: Theme.paddingSmall

        Column {
            width: parent.width - 2*Theme.paddingLarge
            anchors.centerIn: parent
            spacing: Theme.paddingSmall

            Label {
                width: parent.width
                text: title
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.primaryColor
            }

            ProgressBar {
                width: parent.width
                minimumValue: 0
                maximumValue: targetAmount
                value: currentAmount
                label: "Прогресс: " + ((currentAmount/targetAmount)*100).toFixed(1) + "%"
            }

            Label {
                text: "Осталось: " + (targetAmount - currentAmount).toFixed(2) + " ₽"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor
            }

            Label {
                text: "Ежемесячный взнос: " + monthlyPayment + " ₽"
                font.pixelSize: Theme.fontSizeSmall
                color: monthlyPayment > 0 ? Theme.primaryColor : Theme.errorColor
            }
        }
    }

    onClicked: {
        // Редактирование цели
        pageStack.push("EditGoalPage.qml", {goal: model})
    }
}
