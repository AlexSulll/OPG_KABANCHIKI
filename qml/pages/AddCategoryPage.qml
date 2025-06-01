import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0

Page {
    id: addCategoryPage

    property var categoryModel

    property int categoryType: 0
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
                title: qsTr("Добавление новой категории")
            }

            TextField {
                width: parent.width
                label: qsTr("Название категории")
                placeholderText: qsTr(categoryType ? "Стипендия, пенсия..." : "Продукты, Транспорт...")
                onTextChanged: categoryName = text
            }

            ValueButton {
                id: iconButton
                width: parent.width
                label: qsTr("Иконка категории")
                value: iconPath ? iconPath.split("/").pop() : "Не выбрана"

                onClicked: {
                    pageStack.push(filePicker);
                }
            }

            ComboBox {
                width: parent.width
                label: "Тип категории"
                currentIndex: categoryType
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("Расход")
                    }
                    MenuItem {
                        text: qsTr("Доход")
                    }
                }

                onCurrentIndexChanged: {
                    categoryType = currentIndex;
                }
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Сохранить")
                enabled: categoryName.length > 0 && iconPath.length > 0

                onClicked: {
                    var newCategory = {
                        nameCategory: categoryName,
                        typeCategory: categoryType,
                        pathToIcon: iconPath
                    };
                    categoryModel.addCategory(newCategory);
                    pageStack.pop();
                }
            }
        }
    }

    Component {
        id: filePicker

        FilePickerPage {
            title: qsTr("Выберите иконку категории")
            nameFilters: ['*.svg']

            onSelectedContentPropertiesChanged: {
                if (selectedContentProperties !== null) {
                    iconPath = selectedContentProperties.filePath;
                }
            }
        }
    }
}
