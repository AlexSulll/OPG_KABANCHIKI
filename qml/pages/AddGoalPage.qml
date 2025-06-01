import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: addGoalPage

    property var goalModel

    property string date: Qt.formatDate(new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), "dd.MM.yyyy")
    property bool allFieldsValid: titleField.text.trim() !== "" && amountField.text.trim() !== "" && !isNaN(parseFloat(amountField.text)) && parseFloat(amountField.text) > 0

    canAccept: allFieldsValid

    Column {
        width: parent.width

        DialogHeader {
            title: qsTr("Новая цель")
            acceptText: qsTr("Сохранить")
            cancelText: qsTr("Отмена")
        }

        TextField {
            id: titleField
            width: parent.width
            label: qsTr("Название цели")
            placeholderText: qsTr("Например: Новая машина")
        }

        TextField {
            id: amountField
            width: parent.width
            label: qsTr("Целевая сумма")
            inputMethodHints: Qt.ImhDigitsOnly
            validator: DoubleValidator {
                bottom: 1
            }
        }

        TextField {
            id: dateField
            width: parent.width
            label: qsTr("Дата завершения")
            text: date
            readOnly: true

            onClicked: {
                dateDialog.open();
            }
        }
    }

    onAccepted: {
        const newGoal = {
            title: titleField.text,
            targetAmount: parseFloat(amountField.text),
            currentAmount: 0,
            startDate: new Date().toISOString(),
            endDate: datePicker.date.toISOString()
        };
        goalModel.addGoal(newGoal);
    }

    Dialog {
        id: dateDialog

        Column {
            width: parent.width
            spacing: Theme.paddingLarge

            DialogHeader {
                title: qsTr("Выберите дату")
                acceptText: qsTr("ОК")
                cancelText: qsTr("Отмена")
            }

            Label {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: {
                    if (datePicker.date) {
                        var locale = Qt.locale("ru_RU");
                        var monthName = locale.standaloneMonthName(datePicker.date.getMonth());
                        monthName = monthName.charAt(0).toUpperCase() + monthName.slice(1);

                        return monthName + " " + datePicker.date.getFullYear();
                    }

                    return "";
                }
                font.pixelSize: Theme.fontSizeLarge
            }

            DatePicker {
                id: datePicker
                width: parent.width
                date: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)
                onDateChanged: {
                    addGoalPage.date = Qt.formatDate(date, "dd.MM.yyyy");
                }
            }
        }

        onOpened: {
            datePicker.date = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);
        }
    }
}
