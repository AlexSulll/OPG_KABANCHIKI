import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0
import "../services" as Services

Page {
    id: editCategoryPage

    property int categoryType: categoryData ? categoryData.typeCategory : 0
    property string categoryName: categoryData ? categoryData.nameCategory : ""
    property string iconPath: categoryData ? categoryData.pathToIcon : ""

    property var categoryModel
    property var categoryData

    Services.OperationService {
        id: operationService
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("Редактирование категории")
            }

            TextField {
                width: parent.width
                label: qsTr("Название категории")
                placeholderText: qsTr("Продукты, Транспорт...")
                text: categoryName
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
                label: qsTr("Тип категории")
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
                    var updatedCategory = {
                        categoryId: categoryData.categoryId,
                        nameCategory: categoryName,
                        typeCategory: categoryType,
                        pathToIcon: iconPath
                    };
                    categoryModel.updateCategory(updatedCategory);
                    pageStack.pop();
                }
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Удалить категорию")
                color: Theme.errorColor

                onClicked: {
                    confirmDeleteDialog.open();
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

    Dialog {
        id: confirmDeleteDialog
        allowedOrientations: Orientation.All

        Column {
            width: parent.width
            spacing: Theme.paddingLarge

            DialogHeader {
                title: qsTr("Подтверждение удаления")
                acceptText: qsTr("Удалить")
                cancelText: qsTr("Отмена")
            }

            Label {
                width: parent.width
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("Вы уверены, что хотите удалить категорию '%1'?").arg(categoryName)
                color: Theme.errorColor
                font.pixelSize: Theme.fontSizeMedium
            }

            Label {
                width: parent.width
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("Все связанные операции будут сохранены, но потеряют привязку к категории.")
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
            }
        }

        onAccepted: {
            deleteCategory();
        }
    }

    function deleteCategory() {
        operationService.deleteOperationByCategoryId(categoryData.categoryId);
        categoryModel.removeCategory(categoryData.categoryId);
        pageStack.replaceAbove(null, Qt.resolvedUrl("MainPage.qml"));
    }
}
