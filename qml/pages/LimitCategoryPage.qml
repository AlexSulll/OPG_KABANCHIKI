import QtQuick 2.0
import Sailfish.Silica 1.0
import "../models" as Models
import "../components" as Components

Page {
    id: limitPage
    allowedOrientations: Orientation.All

    property var limitModel: Models.LimitModel {}
    property var selectedCategory: null
    property bool isCategorySelected: selectedCategory !== null

    Models.CategoryModel {
        id: categoryModel
        Component.onCompleted: loadCategoriesByType(0)
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingMedium

            PageHeader {
                title: qsTr("Лимиты расходов")
            }

            // Заменяем ComboBox на GridView с категориями
            GridView {
                id: categoriesGrid
                width: parent.width
                height: cellHeight * Math.ceil(count / 3)
                cellWidth: width / 3
                cellHeight: cellWidth * 1.2
                interactive: false

                model: {
                    var filtered = [];
                    for (var i = 0; i < categoryModel.count; i++) {
                        var item = categoryModel.get(i);
                        if (item.categoryId !== 8) { // Исключаем категорию с ID 8
                            filtered.push({
                                categoryId: item.categoryId,
                                nameCategory: item.nameCategory,
                                pathToIcon: item.pathToIcon
                            });
                        }
                    }
                    return filtered;
                }

                delegate: Components.CategoryDelegate {
                    width: GridView.view.cellWidth
                    height: GridView.view.cellHeight
                    categoryId: modelData.categoryId
                    nameCategory: modelData.nameCategory
                    pathToIcon: modelData.pathToIcon
                    isSelected: selectedCategory ? selectedCategory.categoryId === modelData.categoryId : false

                    onCategorySelected: {
                        selectedCategory = {
                            categoryId: categoryId,
                            nameCategory: nameCategory,
                            pathToIcon: pathToIcon
                        };
                        console.log("Selected category:", nameCategory, "ID:", categoryId);
                        updateLimitDisplay();
                    }
                }
            }

            TextField {
                id: limitInput
                width: parent.width
                label: qsTr("Лимит (руб)")
                placeholderText: qsTr("Введите сумму лимита")
                inputMethodHints: Qt.ImhDigitsOnly
                validator: IntValidator { bottom: 1 }
                visible: isCategorySelected
            }

            Label {
                id: currentLimitLabel
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                color: Theme.highlightColor
                visible: isCategorySelected && text !== ""
            }

            Button {
                text: qsTr("Установить лимит")
                anchors.horizontalCenter: parent.horizontalCenter
                enabled: isCategorySelected && limitInput.text !== ""
                onClicked: setCategoryLimit()
                visible: isCategorySelected
            }

            Button {
                text: qsTr("Сбросить лимит")
                anchors.horizontalCenter: parent.horizontalCenter
                enabled: isCategorySelected && limitModel.hasLimit(selectedCategory.categoryId)
                onClicked: resetCategoryLimit()
                visible: isCategorySelected
            }

            Label {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("Выберите категорию для установки лимита")
                color: Theme.secondaryColor
                visible: !isCategorySelected
            }
        }
    }

    function updateLimitDisplay() {
        if (!isCategorySelected) return;

        var currentLimit = limitModel.getLimit(selectedCategory.categoryId);
        console.log("Current limit for", selectedCategory.nameCategory, ":", currentLimit);

        if (currentLimit !== null && currentLimit !== undefined) {
            currentLimitLabel.text = qsTr("Текущий лимит: %1 руб").arg(currentLimit);
            limitInput.text = currentLimit;
        } else {
            currentLimitLabel.text = qsTr("Лимит не установлен");
            limitInput.text = "";
        }
    }

    function setCategoryLimit() {
        if (!isCategorySelected || limitInput.text === "") return;

        var limitAmount = parseInt(limitInput.text);
        if (isNaN(limitAmount)) return;

        limitModel.setLimit(selectedCategory.categoryId, limitAmount);
        showNotification(qsTr("Лимит для '%1' установлен").arg(selectedCategory.nameCategory));
        updateLimitDisplay();
    }

    function resetCategoryLimit() {
        if (!isCategorySelected) return;

        limitModel.removeLimit(selectedCategory.categoryId);
        showNotification(qsTr("Лимит для '%1' сброшен").arg(selectedCategory.nameCategory));
        updateLimitDisplay();
    }

    function showNotification(message) {
        console.log("Notification:", message);
    }
}
