import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: operationPage

    signal operationSaved(var operation)  // Сигнал для передачи данных

    property string amount: ""
    property string date: ""
    property string type: "Расход"
    property string comment: ""

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingLarge
            anchors.top: parent.top
            anchors.topMargin: Theme.paddingLarge

            TextField {
                width: parent.width
                placeholderText: qsTr("Сумма операции")
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                onTextChanged: operationPage.amount = text
            }

            TextField {
                width: parent.width
                placeholderText: qsTr("Дата операции (дд.мм.гггг)")
                inputMethodHints: Qt.ImhDate
                onTextChanged: operationPage.date = text
            }

            ComboBox {
                width: parent.width
                label: qsTr("Тип операции")
                menu: ContextMenu {
                    MenuItem { text: qsTr("Расход") }
                    MenuItem { text: qsTr("Доход") }
                }
                onCurrentIndexChanged: {
                    type = currentItem.text
                }
            }

            TextArea {
                width: parent.width
                height: Theme.itemSizeLarge
                placeholderText: qsTr("Комментарий")
                inputMethodHints: Qt.ImhNoPredictiveText
                onTextChanged: operationPage.comment = text
            }

            Button {
                text: qsTr("Сохранить")
                onClicked: {
                    var operation = {
                        amount: amount,
                        date: date,
                        type: type,
                        comment: comment
                    }
                    operationSaved(operation)  // Отправляем данные на главную страницу
                    pageStack.pop()
                    console.log(JSON.stringify(operation))// Вернуться на главную
                }
            }
        }
    }
}
