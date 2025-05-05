import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: editGoalPage
    allowedOrientations: Orientation.All

    property var goal
    property var goalModel

    // Вычисляемые свойства
    property real monthlyPayment: calculateMonthlyPayment()
//    property bool isValid: titleField.text.length > 0 &&
//                         targetAmountField.valid &&
//                         datePicker.date > new Date()

    function calculateMonthlyPayment() {
        if(!goal) return 0
        const remaining = targetAmountField.text - goal.currentAmount
        const monthsLeft = Math.ceil((datePicker.date - new Date()) / (1000*60*60*24*30))
        return monthsLeft > 0 ? (remaining / monthsLeft).toFixed(2) : 0
    }

    onGoalChanged: {
        if(goal) {
            titleField.text = goal.title
            targetAmountField.text = goal.targetAmount
            datePicker.date = new Date(goal.endDate)
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: contentColumn.height

        Column {
            id: contentColumn
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: "Редактирование цели"
            }

            ProgressBar {
                width: parent.width
                minimumValue: 0
                maximumValue: goal ? goal.targetAmount : 1
                value: goal ? goal.currentAmount : 0
                label: value >= maximumValue ?
                    "Цель достигнута! 🎉" :
                    "Прогресс: " + (value/maximumValue*100).toFixed(1) + "%"
            }

            TextField {
                id: titleField
                width: parent.width
                label: "Название цели"
                placeholderText: "Введите название"
            }

            TextField {
                id: targetAmountField
                width: parent.width
                label: "Целевая сумма (₽)"
                inputMethodHints: Qt.ImhDigitsOnly
                validator: DoubleValidator { bottom: 1 }
            }

            DatePicker {
                id: datePicker
                width: parent.width
//                title: "Дата завершения"
            }

            DetailItem {
                label: "Текущий баланс"
                value: goal ? (goal.currentAmount.toFixed(2) + " ₽") : "0 ₽"
            }

            DetailItem {
                label: "Ежемесячный взнос"
                value: monthlyPayment + " ₽"
//                valueColor: monthlyPayment > 0 ? Theme.primaryColor : Theme.errorColor
            }

            Button {
                text: "Сохранить изменения"
                anchors.horizontalCenter: parent.horizontalCenter
//                enabled: isValid
                onClicked: saveChanges()
            }

            Button {
                text: "Удалить цель"
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.errorColor
                onClicked: deleteGoal()
            }
        }
    }

    function saveChanges() {
        var updatedGoal = {
            id: goal.id,
            title: titleField.text,
            targetAmount: parseFloat(targetAmountField.text),
            endDate: datePicker.date.toISOString()
        }
        goalModel.updateGoal(updatedGoal)
        pageStack.pop()
    }

    function deleteGoal() {
            onTriggered: {
                goalModel.removeGoal(goal.id)
                pageStack.pop()
            }
        }
    }
