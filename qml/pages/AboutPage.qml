import QtQuick 2.0
import Sailfish.Silica 1.0
import "../models"
import "../components"

Page {
    id: aboutPage
    objectName: "aboutPage"
    allowedOrientations: Orientation.All

    // Экземпляр модели
    CategoryModel {
        id: categoryModel
    }

    property var categories: categoryModel.categories

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: contentColumn.height

        Column {
            id: contentColumn
            width: parent.width

            HeaderComponent {
                id: header
                headerText: "Добавление"
                fontSize: Theme.fontSizeExtraLarge
                color: "transparent"
                showIcon: false
            }

            // Grid для отображения категорий
            SilicaGridView {
                id: categoriesGrid
                width: parent.width
                height: cellHeight * Math.ceil(listModel.count / 3)
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingMedium
                }
                clip: true

                cellWidth: width / 3
                cellHeight: cellWidth * 1.2

                model: ListModel {
                    id: listModel
                    Component.onCompleted: updateModel()
                    function updateModel() {
                        clear();
                        for (var i = 0; i < categoryModel.categories.length; i++) {
                            append(categoryModel.categories[i]);
                        }
                    }
                }

                Connections {
                    target: categoryModel
                    onCategoriesChanged: listModel.updateModel()
                }

                delegate: BackgroundItem {
                    width: categoriesGrid.cellWidth
                    height: categoriesGrid.cellHeight
                    clip: true

                    Column {
                        width: parent.width - Theme.paddingMedium*2
                        anchors.centerIn: parent
                        spacing: Theme.paddingSmall

                        Rectangle {
                            width: parent.width * 0.8
                            height: width
                            radius: width/2
                            color: Theme.rgba(Theme.highlightBackgroundColor, 0.2)
                            anchors.horizontalCenter: parent.horizontalCenter

                            Image {
                                source: pathToIcon
                                width: parent.width * 0.6
                                height: width
                                anchors.centerIn: parent
                                sourceSize { width: width; height: height }
                            }
                        }

                        Label {
                            text: nameCategory
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.Wrap
                            font.pixelSize: Theme.fontSizeSmall
                            maximumLineCount: 2
                            elide: Text.ElideRight
                            color: pressed ? Theme.highlightColor : Theme.primaryColor
                        }
                    }

                    onClicked: {
                        console.log("Selected category:", nameCategory, "categoryId:", categoryId);
                    }
                }
            }

            Column {
                id: inputColumn
                width: parent.width
                spacing: Theme.paddingLarge
                anchors.margins: Theme.paddingMedium

                TextField {
                    width: parent.width
                    placeholderText: qsTr("Сумма операции")
                    inputMethodHints: Qt.ImhDigitsOnly
                    validator: IntValidator { bottom: 1 }
                    onTextChanged: operationPage.amount = text
                }

                TextField {
                    id: dateField
                    width: parent.width
                    placeholderText: qsTr("Дата операции (дд.мм.гггг)")
                    onClicked: dateDialog.open()
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
                        operationPage.action = currentIndex
                    }
                }

                TextArea {
                    width: parent.width
                    height: Theme.itemSizeLarge
                    placeholderText: qsTr("Комментарий")
                    inputMethodHints: Qt.ImhNoPredictiveText
                    onTextChanged: operationPage.desc = text
                }

                Button {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Сохранить")
                    onClicked: {
                        if (operationService) {
                            var op = {
                                amount: operationPage.amount,
                                action: operationPage.action,
                                category: operationPage.category,
                                date: operationPage.date,
                                desc: operationPage.desc
                            }
                            operationService.addOperation(op)
                            operationModel.add(op)
                            pageStack.pop()
                        }
                    }
                }
            }
        }
    }

    // Календарь в стиле Sailfish OS
    Dialog {
        id: dateDialog
        width: parent.width
        height: column.height + Theme.paddingLarge * 2
        anchors.centerIn: parent

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingLarge

            DatePicker {
                id: datePicker
                width: parent.width
                date: new Date()
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Готово")
                onClicked: {
                    dateField.text = Qt.formatDate(datePicker.date, "dd.MM.yyyy")
                    dateDialog.close()
                }
            }
        }

        // Закрытие при клике вне области
        MouseArea {
            anchors.fill: parent
            enabled: dateDialog.visible
            onClicked: dateDialog.close()
        }
    }

    function addNewCategory() {
        var newCategory = {
            categoryId: 5,
            nameCategory: "Новая категория",
            pathToIcon: "../icons/Expense/NewIcon.svg"
        };
        categoryModel.addCategory(newCategory);
    }
}
