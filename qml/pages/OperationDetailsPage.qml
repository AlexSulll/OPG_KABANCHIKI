import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: operationDetailsPage
    allowedOrientations: Orientation.All

    property var operationModel
    property var categoryModel
    property int operationId: -1

    property string amount: ""
    property int categoryId: -1
    property string date: ""
    property string desc: ""
    property int action: 0

    property bool isValid: amount.length > 0 && categoryId !== -1

    Component.onCompleted: {
        var op = operationModel.getOperationById(operationId);
        amount = op.amount;
        categoryId = op.categoryId;
        date = op.date;
        desc = op.desc === undefined ? "" : op.desc;
        action = op.action;
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
                validator: IntValidator { bottom: 1 }
            }

            //FIX IF Сделать чтобы название категории было вместе с иконкой категории
            ComboBox {
                width: parent.width
                label: "Категория"
                currentIndex: categoryModel.getIndexById(categoryId)
                value: categoryModel.getCategoryName(categoryId)

                menu: ContextMenu {
                    Repeater {
                        model: categoryModel.filteredCategories(action)
                        delegate: MenuItem {
                            text: modelData.nameCategory
                            onClicked: categoryId = modelData.categoryId
                        }
                    }
                }
            }

            TextField {
                width: parent.width
                label: "Дата"
                text: date
                onClicked: dateDialog2.open()
            }

            TextArea {
                width: parent.width
                height: Theme.itemSizeLarge
                label: "Комментарий"
                text: desc
                onTextChanged: desc = text
            }

            Row {
                width: parent.width
                spacing: Theme.paddingLarge

                Button {
                    width: parent.width/2 - Theme.paddingMedium
                    text: "Удалить"
                    color: Theme.errorColor
                    onClicked: {
                        operationModel.deleteOperation(operationId)
                        pageStack.replaceAbove(null, Qt.resolvedUrl("MainPage.qml"))
                    }
                }

                Button {
                    width: parent.width/2 - Theme.paddingMedium
                    text: "Сохранить"
                    enabled: isValid
                    onClicked: {
                        operationModel.updateOperation({
                            id: operationId,
                            amount: parseInt(amount),
                            action: action,
                            categoryId: categoryId,
                            date: date,
                            desc: desc
                        })
                        pageStack.replaceAbove(null, Qt.resolvedUrl("MainPage.qml"))
                    }
                }
            }
        }
    }

    Dialog {
        id: dateDialog2

        Column {
            DialogHeader {
                title: "Выберите дату"
                acceptText: "ОК"
                cancelText: "Отмена"
            }

            DatePicker {
                id: datePicker
                date: operationModel.parseDate(operationDetailsPage.date)
                onDateChanged: {
                    operationDetailsPage.date = Qt.formatDate(date, "dd.MM.yyyy");
                }
            }
        }
    }
}
