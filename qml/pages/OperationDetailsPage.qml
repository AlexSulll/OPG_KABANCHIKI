import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"
import "../services" as Services
import "../models" as Models

Page {
    id: operationDetailsPage
    allowedOrientations: Orientation.All

    // Принимаемые параметры
    property var operationModel
    property var categoryModel
    property var operationData: ({})
    property int operationId: -1

    // Локальные свойства для редактирования
    property string amount: ""
    property int categoryId: -1
    property string date: ""
    property string desc: ""
    property int action: 0

    // Сервисы
    Services.OperationService {
        id: operationService
    }

    Services.CategoryService {
        id: categoryService
    }

    // Инициализация данных
    Component.onCompleted: {
        if (operationId !== -1) {
            var op = operationModel.getOperationById(operationId)
            if (op) {
                amount = op.amount
                categoryId = op.categoryId
                date = op.date
                desc = op.desc
                action = op.action
            }
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
                title: "Редактирование операции"
            }

            TextField {
                width: parent.width
                label: "Сумма"
                placeholderText: "Введите сумму"
                inputMethodHints: Qt.ImhDigitsOnly
                text: amount
                onTextChanged: amount = text
                validator: DoubleValidator {
                    bottom: 0.01
                    locale: "en_US"
                }
            }

            ComboBox {
                width: parent.width
                label: "Категория"
                currentIndex: {
                    for (var i = 0; i < categoryModel.count; i++) {
                        if (categoryModel.get(i).categoryId === categoryId) return i
                    }
                    return -1
                }

                menu: ContextMenu {
                    Repeater {
                        model: categoryModel
                        delegate: MenuItem {
                            text: model.nameCategory
                            onClicked: categoryId = model.categoryId
                        }
                    }
                }
            }

            TextField {
                width: parent.width
                label: "Дата"
                placeholderText: "дд.мм.гггг"
                text: Qt.formatDate(new Date(date), "dd.MM.yyyy")
                onClicked: dateDialog.open()
            }

            TextArea {
                width: parent.width
                height: Theme.itemSizeLarge
                label: "Комментарий"
                text: desc
                onTextChanged: desc = text
            }

            SectionHeader {
                text: "Тип операции"
            }

            TextSwitch {
                text: "Доход"
                checked: action === 1
                onClicked: action = checked ? 1 : 0
            }

            Row {
                width: parent.width
                spacing: Theme.paddingLarge

                Button {
                    width: parent.width / 2 - Theme.paddingMedium
                    text: "Удалить"
                    color: Theme.errorColor
                    onClicked: deleteOperation()
                }

                Button {
                    width: parent.width / 2 - Theme.paddingMedium
                    text: "Сохранить"
                    enabled: amount.length > 0 && categoryId !== -1
                    onClicked: saveOperation()
                }
            }
        }
    }

    Dialog {
        id: dateDialog
        DialogHeader { title: "Выберите дату" }

        DatePicker {
            id: datePicker
            date: new Date(operationData.date)
            onDateChanged: {
                operationDetailsPage.date = Qt.formatDate(date, "yyyy-MM-dd")
                dateDialog.close()
            }
        }
    }

    function saveOperation() {
        var operation = {
            id: operationId,
            amount: parseFloat(amount),
            action: action,
            categoryId: categoryId,
            date: date,
            desc: desc
        }

        operationService.updateOperation(operation)
        operationModel.refresh()
        pageStack.pop()
    }

    function deleteOperation() {
        Remorse.popupAction(operationDetailsPage, "Удаление", function() {
            operationService.deleteOperation(operationId)
            operationModel.refresh()
            pageStack.pop()
        })
    }
}
