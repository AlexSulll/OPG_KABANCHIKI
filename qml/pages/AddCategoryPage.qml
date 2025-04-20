import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0

Page {
    id: addCategoryPage

    property var categoryModel
    property int categoryType: 0 // 0 - расходы, 1 - доходы

    property string categoryName: ""
    property string iconPath: ""

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader { title: "Добавление новой категории" }

            TextField {
                width: parent.width
                label: "Название категории"
                placeholderText: "Продукты, Транспорт..."
                onTextChanged: categoryName = text
            }

            ValueButton {
                id: iconButton
                width: parent.width
                label: "Иконка категории"
                value: iconPath ? iconPath.split("/").pop() : "Не выбрана"
                onClicked: {
                    pageStack.push(filePicker)
                }
            }

            ComboBox {
                width: parent.width
                label: "Тип категории"
                currentIndex: categoryType
                menu: ContextMenu {
                    MenuItem { text: "Расход" }
                    MenuItem { text: "Доход" }
                }
                onCurrentIndexChanged: {
                    categoryType = currentIndex
                }
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Сохранить"
                enabled: categoryName.length > 0 && iconPath.length > 0
                onClicked: {
                    var newCategory = {
                        nameCategory: categoryName,
                        typeCategory: categoryType,
                        pathToIcon: iconPath
                    }
                    console.log(JSON.stringify(newCategory));
                    categoryModel.addCategory(newCategory)
                    pageStack.pop()
                }
            }
        }
    }

    Component {
        id: filePicker

        FilePickerPage {
            title: qsTr("Выберите иконку категории")
            nameFilters: [ '*.svg' ]

            onSelectedContentPropertiesChanged: {
                if (selectedContentProperties !== null) {
                    iconPath = selectedContentProperties.filePath
                }
            }
        }
    }
}
