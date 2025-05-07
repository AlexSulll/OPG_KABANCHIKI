import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: operationDetailsPage
    allowedOrientations: Orientation.All

    property int operationId: -1
    property string amount: ""
    property int categoryId: -1
    property string date: ""
    property string desc: ""
    property int action: 0
    property bool isValid: amount.length > 0 && categoryId !== -1

    property var operationModel
    property var categoryModel

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
                title: "Просмотр и редактирование операции"
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

            ComboBox {
                id: categoryCombo
                width: parent.width
                currentIndex: categoryModel.getIndexById(categoryId)

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.horizontalPageMargin
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.paddingMedium

                    Image {
                        source: categoryModel.getCategoryIcon(categoryId) || ""
                        width: Theme.iconSizeSmall
                        height: Theme.iconSizeSmall
                        visible: Boolean(source)
                    }

                    Label {
                        text: categoryModel.getCategoryName(categoryId)
                        truncationMode: TruncationMode.Fade
                    }
                }

                menu: ContextMenu {
                    Repeater {
                        model: categoryModel.filteredCategories(action)
                        delegate: Component {
                            Item {
                                width: parent.width
                                height: Theme.itemSizeSmall

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        categoryId = modelData.categoryId;
                                    }
                                }

                                Row {
                                    anchors.fill: parent
                                    spacing: Theme.paddingMedium
                                    anchors.leftMargin: Theme.paddingLarge*1.1

                                    Image {
                                        source: modelData.pathToIcon || ""
                                        width: Theme.iconSizeSmall
                                        height: Theme.iconSizeSmall
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Label {
                                        text: modelData.nameCategory
                                        width: parent.width - x - Theme.paddingMedium
                                        anchors.verticalCenter: parent.verticalCenter
                                        color: pressed ? Theme.highlightColor : Theme.primaryColor
                                    }
                                }
                            }
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
            width: parent.width
            spacing: Theme.paddingLarge

            DialogHeader {
                title: "Выберите дату"
                acceptText: "ОК"
                cancelText: "Отмена"
            }

            Label {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: {
                    if (datePicker.date) {
                        var locale = Qt.locale("ru_RU")
                        var monthName = locale.standaloneMonthName(datePicker.date.getMonth())
                        monthName = monthName.charAt(0).toUpperCase() + monthName.slice(1)
                        return monthName + " " + datePicker.date.getFullYear()
                     }
                     return ""
                }
                font.pixelSize: Theme.fontSizeLarge
            }

            DatePicker {
                id: datePicker
                date: operationModel.parseDate(operationDetailsPage.date)
                onDateChanged: {
                    operationDetailsPage.date = Qt.formatDate(date, "dd.MM.yyyy");
                }
            }
        }
        
        onOpened: {
            datePicker.date = new Date()
        }
    }
}
