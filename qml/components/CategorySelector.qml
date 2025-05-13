import QtQuick 2.0
import Sailfish.Silica 1.0

ComboBox {
    id: categorySelector
    width: parent.width
    label: "Категория"

    property var categoryModel
    property int selectedCategoryId: -1
    property int currentCategoryType: 0
    property bool initialized: false

    property var filteredCategories: {
        var result = [];
        if (categoryModel) {
            for (var i = 0; i < categoryModel.count; i++) {
                var cat = categoryModel.get(i);
                if (cat.categoryId !== 8 && cat.categoryId !== 13) {
                    result.push(cat);
                }
            }
        }
        return result;
    }

    menu: ContextMenu {
        MenuItem {
            text: "Выберите категорию"
            onClicked: {
                selectedCategoryId = -1;
                currentIndex = 0;
            }
        }

        Repeater {
            model: filteredCategories

            delegate: MenuItem {
                text: modelData.nameCategory
                onClicked: {
                    selectedCategoryId = modelData.categoryId;
                }
            }
        }
    }

    onCurrentCategoryTypeChanged: {
        if (initialized) {
            resetSelection();
        }
    }

    Component.onCompleted: {
        initialized = true;
        resetSelection();
    }

    function resetSelection() {
        selectedCategoryId = -1;
        currentIndex = 0;
    }

    onSelectedCategoryIdChanged: {
        if (selectedCategoryId === -1) {
            currentIndex = 0;
        } else {
            for (var i = 0; i < filteredCategories.length; i++) {
                if (filteredCategories[i].categoryId === selectedCategoryId) {
                    currentIndex = i + 1;
                    break;
                }
            }
        }
    }
}
