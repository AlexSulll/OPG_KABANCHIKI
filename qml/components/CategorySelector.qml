import QtQuick 2.0
import Sailfish.Silica 1.0

ComboBox {
    id: categorySelector
    width: parent.width
    label: "Категория"

    property var categoryModel
    property int selectedCategoryId: -1
    property int currentCategoryType: 0 // 0 - расход, 1 - доход

    // Обновляем список при изменении типа категории
    onCurrentCategoryTypeChanged: {
        categoryModel.loadCategoriesByType(currentCategoryType)
    }

    menu: ContextMenu {
        Repeater {
            model: categoryModel

            delegate: MenuItem {
                text: nameCategory
                onClicked: {
                    selectedCategoryId = categoryId
                }
            }
        }
    }

    // Инициализация и обновления
    Component.onCompleted: {
        if (categoryModel) {
            categoryModel.loadCategoriesByType(currentCategoryType)
        }
    }

    // Обновление выбранного значения
    onSelectedCategoryIdChanged: {
        if (selectedCategoryId > 0) {
            var index = categoryModel.getIndexById(selectedCategoryId)
            if (index >= 0) {
                currentIndex = index
            }
        } else {
            currentIndex = -1
            currentItem.text = "Выберите категорию"
        }
    }
}
