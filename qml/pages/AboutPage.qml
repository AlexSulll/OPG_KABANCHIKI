import QtQuick 2.0
import Sailfish.Silica 1.0
import "../models"
import "../components"

Page {
    id: aboutPage
    objectName: "aboutPage"
    allowedOrientations: Orientation.All

    // Экземпляр модели
    CategoryModel {
        id: categoryModel
    }

    property var categories: categoryModel.categories

    HeaderComponent {
        id: header
        headerText: "Добавление"
        fontSize: Theme.fontSizeExtraLarge
        color: "transparent"
        showIcon: false
    }

    // Grid для отображения категорий
    SilicaGridView {
        id: categoriesGrid
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: Theme.paddingMedium
        }
        clip: true

        cellWidth: width / 3
        cellHeight: cellWidth * 1.2

        model: ListModel {
            id: listModel
            Component.onCompleted: updateModel()
            function updateModel() {
                clear();
                for (var i = 0; i < categoryModel.categories.length; i++) {
                    append(categoryModel.categories[i]);
                }
            }
        }

        Connections {
            target: categoryModel
            onCategoriesChanged: listModel.updateModel()
        }

        // Отображение категорий
        delegate: BackgroundItem {
            width: categoriesGrid.cellWidth
            height: categoriesGrid.cellHeight
            clip: true

            Column {
                width: parent.width - Theme.paddingMedium*2
                anchors.centerIn: parent
                spacing: Theme.paddingSmall

                Rectangle {
                    width: parent.width * 0.8
                    height: width
                    radius: width/2
                    color: Theme.rgba(Theme.highlightBackgroundColor, 0.2)
                    anchors.horizontalCenter: parent.horizontalCenter

                    Image {
                        source: pathToIcon
                        width: parent.width * 0.6
                        height: width
                        anchors.centerIn: parent
                        sourceSize { width: width; height: height }
                    }
                }

                Label {
                    text: nameCategory
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    font.pixelSize: Theme.fontSizeSmall
                    maximumLineCount: 2
                    elide: Text.ElideRight
                    color: pressed ? Theme.highlightColor : Theme.primaryColor
                }
            }
            /*
              Здесь хочу организовать автоматическое переключение на твои поля
              которые потом будут располагаться ниже и выскакивающая клава с цифрами
            */
            onClicked: {
                console.log("Selected category:", nameCategory, "categoryId:", categoryId);
            }
        }
        /*
          Тут прикреплён или скопирован твоя форма
        */
        VerticalScrollDecorator {}
    }

    // Нагенерено
    function addNewCategory() {
        var newCategory = {
            categoryId: 5,
            nameCategory: "Новая категория",
            pathToIcon: "../icons/Expense/NewIcon.svg"
        };
        categoryModel.addCategory(newCategory);
    }
}
