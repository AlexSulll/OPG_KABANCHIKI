import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: editGoalPage
    allowedOrientations: Orientation.All

    property var goal
    property var goalModel

    property string date: ""

    property real monthlyPayment: calculateMonthlyPayment()

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

            TextField {
                width: parent.width
                placeholderText: "Дата"
                label: "Дата завершения цели"
                readOnly: true
                text: date
                onClicked: dateDialog.open()
            }

            DetailItem {
                label: "Текущий баланс"
                value: goal ? (goal.currentAmount.toFixed(2) + " ₽") : "0 ₽"
            }

            DetailItem {
                label: "Ежемесячный взнос"
                value: monthlyPayment + " ₽"
            }

            Button {
                text: "Сохранить изменения"
                anchors.horizontalCenter: parent.horizontalCenter
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

    Dialog {
        id: dateDialog
        allowedOrientations: Orientation.All

        Column {
            width: parent.width
            spacing: Theme.paddingLarge

            DialogHeader {
                title: "Выберите дату"
                acceptText: "ОК"
                cancelText: "Отмена"
            }

            Row {
                width: parent.width
                spacing: Theme.paddingMedium

                ComboBox {
                    id: monthCombo
                    width: parent.width / 2 - Theme.paddingMedium/2
                    label: "Месяц"
                    currentIndex: datePicker.date.getMonth()

                    menu: ContextMenu {
                        Repeater {
                            model: {
                                var locale = Qt.locale("ru_RU")
                                var months = []
                                for (var i = 0; i < 12; i++) {
                                    var monthName = locale.standaloneMonthName(i, Locale.LongFormat)
                                    months.push(monthName.charAt(0).toUpperCase() + monthName.slice(1))
                                }
                                return months
                            }
                            MenuItem { text: modelData }
                        }
                    }

                    onCurrentIndexChanged: {
                        if (datePicker.date) {
                            var newDate = new Date(datePicker.date)
                            newDate.setMonth(currentIndex)
                            datePicker.date = newDate
                        }
                    }
                }

                ComboBox {
                    id: yearCombo
                    width: parent.width / 2 - Theme.paddingMedium/2
                    label: "Год"
                    currentIndex: 5

                    property var years: (function() {
                        var arr = []
                        var currentYear = new Date().getFullYear()
                        for (var i = currentYear - 3; i <= currentYear + 3; i++) {
                            arr.push(i)
                        }
                        return arr
                    })()

                    menu: ContextMenu {
                        Repeater {
                            model: yearCombo.years
                            MenuItem { text: modelData }
                        }
                    }

                    onCurrentIndexChanged: {
                        if (datePicker.date) {
                            var newDate = new Date(datePicker.date)
                            newDate.setFullYear(years[currentIndex])
                            datePicker.date = newDate
                        }
                    }
                }
            }

            DatePicker {
                id: datePicker
                width: parent.width

                onDateChanged: {
                    monthCombo.currentIndex = date.getMonth()
                    yearCombo.currentIndex = yearCombo.years.indexOf(date.getFullYear())
                    editGoalPage.date = Qt.formatDate(date, "dd.MM.yyyy")
                }
            }
        }

        onAccepted: {
            editGoalPage.date = Qt.formatDate(datePicker.date, "dd.MM.yyyy")
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
