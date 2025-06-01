import QtQuick 2.0
import Sailfish.Silica 1.0
import "../models" as Models
import "../components" as Components

Page {
    id: categoryPage

    allowedOrientations: Orientation.All

    property int action: 0
    property bool fromMainButton: true
    property int selectedCategoryId: -1
    property int editingCategoryId: -1

    property var sectorModel
    property var categoryModel
    property var operationModel

    Models.CategoryModel {
        id: categoryModel
    }

    onActionChanged: {
        if (fromMainButton === true) {
            categoryModel.loadCategoriesByType(action);
        } else {
            categoryModel.filteredCategories(action);
        }
    }

    Component.onCompleted: {
        if (fromMainButton === true) {
            categoryModel.loadCategoriesByType(action);
        } else {
            categoryModel.filteredCategories(action);
        }
    }

    onVisibleChanged: {
        if (fromMainButton === true) {
            categoryModel.loadCategoriesByType(action);
        } else {
            categoryModel.filteredCategories(action);
        }
    }

    SilicaFlickable {
        anchors.fill: parent

        Column {
            id: contentColumn
            width: parent.width
            spacing: Theme.paddingLarge

            Components.HeaderComponent {
                id: header
                headerText: qsTr(fromMainButton ? "Добавление" : "Категории")
                fontSize: Theme.fontSizeExtraLarge * 2
                color: "transparent"
                showIcon: true
            }

            Item {
                id: gridFixContainer
                width: parent.width
                height: 1200
                clip: true

                SilicaFlickable {
                    anchors.fill: parent
                    contentHeight: categoriesGrid.height

                    GridView {
                        id: categoriesGrid
                        width: parent.width
                        cellWidth: width / 3
                        cellHeight: cellWidth * 1.2
                        height: categoryPage.height
                        model: categoryModel
                        interactive: false

                        delegate: Item {
                            width: GridView.view.cellWidth
                            height: GridView.view.cellHeight

                            Components.CategoryDelegate {
                                id: categoryDelegate
                                width: parent.width - Theme.paddingMedium
                                height: parent.height - Theme.paddingMedium
                                anchors.centerIn: parent
                                categoryId: model.categoryId
                                nameCategory: model.nameCategory
                                pathToIcon: model.pathToIcon
                                isSelected: selectedCategoryId === model.categoryId
                                visible: editingCategoryId !== model.categoryId

                                onCategorySelected: {
                                    if (fromMainButton) {
                                        if (categoryId === 8 || categoryId === 13) {
                                            pageStack.push(Qt.resolvedUrl("AddCategoryPage.qml"), {
                                                categoryType: action,
                                                categoryModel: categoryModel
                                            });
                                        } else {
                                            pageStack.push(Qt.resolvedUrl("OperationPage.qml"), {
                                                action: action,
                                                selectedCategoryId: categoryId,
                                                operationModel: operationModel,
                                                categoryModel: categoryModel,
                                                fromMainButton: fromMainButton
                                            });
                                        }
                                    } else {
                                        var category = categoryModel.getCategoryById(categoryId);
                                        pageStack.push(Qt.resolvedUrl("EditCategoryPage.qml"), {
                                            categoryModel: categoryModel,
                                            categoryData: category
                                        });
                                    }
                                }
                            }
                        }

                        onModelChanged: {
                            currentIndex = -1;
                            positionViewAtBeginning();
                        }
                    }
                }

                VerticalScrollDecorator {}
            }
        }
    }
}
