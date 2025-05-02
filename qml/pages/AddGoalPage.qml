import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: addGoalPage

    property var goalModel

    Column {
        width: parent.width

        DialogHeader {
            title: "Новая цель"
            acceptText: "Сохранить"
        }

        TextField {
            id: titleField
            width: parent.width
            label: "Название цели"
            placeholderText: "Например: Новая машина"
        }

        TextField {
            id: amountField
            width: parent.width
            label: "Целевая сумма"
            inputMethodHints: Qt.ImhDigitsOnly
            validator: DoubleValidator { bottom: 1 }
        }

        DatePicker {
            id: datePicker
            width: parent.width
            date: new Date()
//            title: "Планируемая дата достижения"
        }
    }

    onAccepted: {
        const newGoal = {
            title: titleField.text,
            targetAmount: parseFloat(amountField.text),
            currentAmount: 0,
            startDate: new Date().toISOString(),
            endDate: datePicker.date.toISOString()
        }
        goalModel.addGoal(newGoal)
    }
}
