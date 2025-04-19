import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components" as Components  // Импорт кастомных компонентов

Page {
    id: categoryPage
    allowedOrientations: Orientation.All

    // Принимаемые параметры
    property var categoryModel
    property int action: 0
    property var mainPage: null

    // Локальные свойства
    property int selectedCategoryId: -1

    onActionChanged: {
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

            // Фиксированный контейнер для сетки с прокруткой
            Item {
                id: gridFixContainer
                width: parent.width
                height: 900   // Фиксированная высота контейнера
                clip: true // Обрезаем содержимое за пределами

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
                                var page = pageStack.push(Qt.resolvedUrl("OperationPage.qml"), {
                                        action: action,
                                        selectedCategoryId: categoryId // Передаем ID выбранной категории
                                });
                            }
                        }

                        // Обновляем позицию при изменении модели
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
