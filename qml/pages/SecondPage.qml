import QtQuick 2.0
import Sailfish.Silica 1.0
//import QtQuick.Controls 2.15

Page {
    id: operationPage

    signal operationSaved(var operation)  // Сигнал для передачи данных

    property string amount: ""
    property int action: 0
    property string category: ""
    property string date: ""
    property string desc: ""
    property var operationModel

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingLarge
            anchors.top: parent.top
            anchors.topMargin: Theme.paddingLarge

            // Поле для суммы операции, ограничение на ввод чисел
            TextField {
                width: parent.width
                placeholderText: qsTr("Сумма операции")
                inputMethodHints: Qt.ImhFormattedNumbersOnly  // Ограничиваем ввод только числами
//                validator: DoubleValidator {

//                }

                onTextChanged: operationPage.amount = text
            }

            // Поле для ввода даты, при нажатии откроется календарь
            TextField {
                width: parent.width
                placeholderText: qsTr("Дата операции (дд.мм.гггг)")
                text: date // отображение текущей даты

                // Открытие всплывающего окна с календарем
                onClicked: dateDialog.open()

                // Когда пользователь вручную изменяет дату
                onTextChanged: operationPage.date = text
            }

            // Всплывающее окно с календарем
            Dialog {
                id: dateDialog
                width: parent.width
                height: parent.height / 2
                DatePicker {
                    anchors.fill: parent
                    ListModel {
                        ListElement { date: "2025-04-16" }  // Начальная дата
                    }
                    onDateChanged: {
                        operationPage.date = Qt.formatDate(date, "dd.MM.yyyy")  // Форматируем в нужный формат
                        dateDialog.close()  // Закрыть всплывающее окно после выбора
                    }
                }
            }

            // Комбо-бокс для выбора типа операции
            ComboBox {
                width: parent.width
                label: qsTr("Тип операции")
                menu: ContextMenu {
                    MenuItem { text: qsTr("Расход") }
                    MenuItem { text: qsTr("Доход") }
                }
                onCurrentIndexChanged: {
                    action = currentIndex
                }
            }

            // Поле для комментария
            TextArea {
                width: parent.width
                height: Theme.itemSizeLarge
                placeholderText: qsTr("Комментарий")
                inputMethodHints: Qt.ImhNoPredictiveText
                onTextChanged: operationPage.desc = text
            }

            // Кнопка сохранения
            Button {
                text: qsTr("Сохранить")
                onClicked: {
                    if (operationModel) {
                        operationModel.addOperation({
                            amount: amount,
                            action: action,
                            category: category,
                            date: date,
                            desc: desc
                        })
                    }
                    pageStack.pop()  // Возвращаемся на главную страницу
                }
            }
        }
    }
}
