import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components" as Components  // Импорт кастомных компонентов

Page {
    id: operationPage
    allowedOrientations: Orientation.All

    // Принимаемые параметры
    property var operationService
    property var categoryModel
    property int action: 0

    // Локальные свойства
    property string amount: ""
    property int selectedCategoryId: -1
    property string date: Qt.formatDate(new Date(), "dd.MM.yyyy")
    property string desc: ""

    Component.onCompleted: {
        if (categoryModel) {
            categoryModel.loadCategoriesByType(action);
        }
    }

    onActionChanged: {
        console.log("Получено действие:", action);
        if (categoryModel) {
            categoryModel.loadCategoriesByType(action);
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: contentColumn.height

        Column {
            id: contentColumn
            width: parent.width
            spacing: Theme.paddingLarge

            // Кастомный заголовок
            Components.HeaderComponent {
                id: header
                headerText: "Добавление"
                fontSize: Theme.fontSizeExtraLarge
                color: "transparent"
                showIcon: false
            }

            // Сетка категорий
            GridView {
                id: categoriesGrid
                width: parent.width
                height: cellHeight * Math.ceil(categoryModel.count / 3)
                cellWidth: width / 3
                cellHeight: cellWidth * 1.2
                model: categoryModel

                delegate: Components.CategoryDelegate {
                    categoryId: model.categoryId
                    nameCategory: model.nameCategory
                    pathToIcon: model.pathToIcon
                    isSelected: selectedCategoryId === model.categoryId
                    onCategorySelected: selectedCategoryId = model.categoryId
                }
            }

            // Поля ввода
            TextField {
                width: parent.width
                placeholderText: "Сумма (руб)"
                inputMethodHints: Qt.ImhDigitsOnly
                validator: IntValidator { bottom: 1 }
                onTextChanged: amount = text
            }

            TextField {
                width: parent.width
                placeholderText: "Дата"
                text: date
                onClicked: dateDialog.open()
            }

            // Кнопка сохранения
            Button {
                text: "Сохранить"
                anchors.horizontalCenter: parent.horizontalCenter
                enabled: amount !== "" && selectedCategoryId !== -1
                onClicked: {
                    if (operationService) {
                        operationService.addOperation({
                            amount: parseInt(amount),
                            action: action,
                            category: selectedCategoryId,
                            date: date,
                            desc: desc
                        });
                        Qt.callLater(function() { pageStack.pop(); });
                    }
                }
            }
        }
    }

    // Диалог выбора даты
    Dialog {
        id: dateDialog
        width: parent.width

        DatePicker {
            id: datePicker
            date: new Date()
            onDateChanged: {
                operationPage.date = Qt.formatDate(date, "dd.MM.yyyy");
                dateDialog.close();
            }
        }
    }
}
