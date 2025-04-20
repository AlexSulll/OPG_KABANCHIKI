import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: addCategoryPage

    // Свойства для передачи извне
    property var categoryModel
    property int categoryType: 0 // 0 - расходы, 1 - доходы

    // Локальные свойства
    property string categoryName: ""
    property string iconPath: ""

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: "Новая категория"
            }

            // Поле ввода названия
            TextField {
                id: nameField
                width: parent.width
                label: "Название категории"
                placeholderText: "Введите название"
                onTextChanged: categoryName = text
            }

            // Поле выбора иконки
            TextField {
                id: iconField
                width: parent.width
                z: 5
                label: "Путь к иконке"
                placeholderText: "Введите путь к файлу"
                onTextChanged: iconPath = text

                // Кнопка выбора файла
                Button {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Выбрать"
                    z: 1
                    onClicked: {
                        // Здесь можно добавить логику выбора файла
                        console.log("Выбор файла иконки")
                    }
                }
            }

            // Переключатель типа категории
            ComboBox {
                width: parent.width
                label: "Тип категории"
                currentIndex: categoryType
                menu: ContextMenu {
                    MenuItem { text: "Расход" }
                    MenuItem { text: "Доход" }
                }
                onCurrentIndexChanged: categoryType = currentIndex
            }

            // Кнопка сохранения
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Сохранить"
                enabled: categoryName.length > 0 && iconPath.length > 0

                onClicked: {
                    // Создаем объект категории
                    var newCategory = {
                        "nameCategory": categoryName,
                        "typeCategory": categoryType,
                        "pathToIcon": iconPath
                    }

                    // Добавляем в модель
                    if(categoryModel) {
                        categoryModel.addCategory(newCategory)
                        pageStack.pop() // Возвращаемся назад
                    } else {
                        console.error("Модель категорий не подключена!")
                    }
                }
            }
        }
    }
}
