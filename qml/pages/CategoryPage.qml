import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components" as Components

Page {
    id: categoryPage
    allowedOrientations: Orientation.All

    property var categoryModel
    property var operationModel
    property int action: 0

    property int selectedCategoryId: -1

    onActionChanged: {
        if (categoryModel) {
            categoryModel.loadCategoriesByType(action);
        }
    }

    Component.onCompleted: {
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

            Components.HeaderComponent {
                id: header
                headerText: "Добавление"
                fontSize: Theme.fontSizeExtraLarge
                color: "transparent"
                showIcon: false
            }

            Item {
                id: gridFixContainer
                width: parent.width
                height: 900
                clip: true

                SilicaFlickable {
                    anchors.fill: parent
                    contentHeight: categoriesGrid.height

                    GridView {
                        id: categoriesGrid
                        width: parent.width
                        cellWidth: width / 3
                        cellHeight: cellWidth * 1.2
                        height: Math.max(implicitHeight, 900)
                        model: categoryModel
                        interactive: false

                        delegate: Components.CategoryDelegate {
                            categoryId: model.categoryId
                            nameCategory: model.nameCategory
                            pathToIcon: model.pathToIcon
                            isSelected: selectedCategoryId === model.categoryId
                            onCategorySelected: {
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
                                        categoryModel: categoryModel
                                });
                                }
                            }
                        }

                        onModelChanged: {
                            currentIndex = -1
                            positionViewAtBeginning()
                        }
                    }
                }
                VerticalScrollDecorator {}
            }
        }
    }
}
