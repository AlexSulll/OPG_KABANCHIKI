import QtQuick 2.0
import Sailfish.Silica 1.0
import "../models"
import "../components"

Page {
    id: operationPage
    objectName: "OperationPage"
    allowedOrientations: Orientation.All

    // Экземпляр модели
    CategoryModel {
        id: categoryModel
    }

    property var categories: categoryModel.categories

    property string amount: ""
    property int action: 0
    property int selectedCategoryId: -1 // Хранит ID выбранной категории
    property string date: ""
    property string desc: ""
    property var operationModel
    property var operationService

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
                    id: delegateItem
                    width: categoriesGrid.cellWidth
                    height: categoriesGrid.cellHeight
                    clip: true

                    // Фон для выделения
                    Rectangle {
                        anchors.fill: parent
                        color: selectedCategoryId === categoryId ? Theme.rgba(Theme.highlightBackgroundColor, 0.2) : "transparent"
                        radius: Theme.paddingSmall
                    }

                    Column {
                        width: parent.width - Theme.paddingMedium*2
                        anchors.centerIn: parent
                        spacing: Theme.paddingSmall

                        Rectangle {
                            width: parent.width * 0.8
                            height: width
                            radius: width/2
                            color: selectedCategoryId === categoryId ? Theme.highlightColor : Theme.rgba(Theme.highlightBackgroundColor, 0.2)
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
                            color: selectedCategoryId === categoryId ? Theme.highlightColor : (pressed ? Theme.highlightColor : Theme.primaryColor)
                        }
                    }

                    onClicked: {
                        console.log("Selected category:", nameCategory, "categoryId:", categoryId);
                        operationPage.selectedCategoryId = selectedCategoryId; // Обновляем выбранную категорию
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
                    width: parent.width
                    placeholderText: qsTr("Дата операции (дд.мм.гггг)")
                    text: date
                    onClicked: dateDialog.open()
                    onTextChanged: operationPage.date = text
                }

                Dialog {
                    id: dateDialog
                    width: parent.width
                    height: parent.height / 2
                    DatePicker {
                        anchors.fill: parent
                        date: new Date()
                        onDateChanged: {
                            operationPage.date = Qt.formatDate(date, "dd.MM.yyyy")  // Форматируем в нужный формат
                            dateDialog.close()  // Закрыть всплывающее окно после выбора
                        }
                    }
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
                    id: saveButton
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Сохранить")
                    onClicked: {
                        if (operationService) {
                            var op = {
                                amount: amount,
                                action: action,
                                category: category,
                                date: date,
                                desc: desc
                            }
                            console.log("pageStack")
                            /*
                              TODO: Кнопка в принципе не работает, даже ничего не выводит по какой-то причине
                              */
                            operationService.addOperation(op)
                            operationModel.add(op)
                            pageStack.pop()
                        }
                    }
                }
            }
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
