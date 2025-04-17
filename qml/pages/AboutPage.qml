/*
    ! Название файла впоследствии поменять на более логичное

    Отдельная от общего шаблона страница с добавлением item
*/
import QtQuick 2.0
import Sailfish.Silica 1.0
import "../models"

Page {
    id: aboutPage
    objectName: "aboutPage"
    allowedOrientations: Orientation.All

    // Экземпляр модели
    CategoryModel {
        id: categoryModel
    }

    // Свойство для доступа к данным модели
    property var categories: categoryModel.categories

    // Контрейнер для с текста "Добавление" и сдвига кнопок категорий
    // от Авроровской кнопки перехода "Назад" -
    // можешь изменить color: "red" для просмотра
    Rectangle {
        id: titleAdd
        height: aboutPage.height / 10
        width: aboutPage.width
        color: Theme.backgroundGlowColor
        Text {
            text: "Добавление"
            anchors.centerIn: titleAdd
            font.pixelSize: Theme.fontSizeExtraLarge*1.25
            color: "white"
        }
    }

    // Grid для отображения категорий
    SilicaGridView {
        id: categoriesGrid
        anchors {
            top: titleAdd.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: Theme.paddingMedium
        }
        clip: true

        cellWidth: width / 3
        cellHeight: cellWidth * 1.2

        /*
        Здесь нагенеренная логика обработки -
        из массива статик (твой ИЗМЕНЁННЫЙ файл CategoryModel) достаёт
        */

        // Используем массив как модель через ListModel
        model: ListModel {
            id: listModel

            // Обновляем ListModel при изменении массива
            Component.onCompleted: updateModel()

            function updateModel() {
                clear();
                for (var i = 0; i < categoryModel.categories.length; i++) {
                    append(categoryModel.categories[i]);
                }
            }
        }

        // Следим за изменениями в массиве категорий
        Connections {
            target: categoryModel
            onCategoriesChanged: listModel.updateModel()
        }

        /*
        */

        // Расположение элементов категории на странице
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

            // Здесь хочу добавить автоматический переход на поле
            // (ещё не склеенные) "Введите сумму" и выпадение компнента
            // KeyPad вроде - клава только с цифрами
            onClicked: {
                console.log("Selected category:", nameCategory, "categoryId:", categoryId);
            }
        }

        /*
          Тут внизу надо добавить отображение полей, которые ты создал в
          Second..... - можно подключить (задав размеры совободной области),
          можно просто вкинуть сюда же
        */

        VerticalScrollDecorator {}
    }

    /*
      Дальше тоже генера с отображения (пока только) статика из CategoryModel
    */

    // Пример добавления новой категории
    function addNewCategory() {
        var newCategory = {
            categoryId: 5,
            nameCategory: "Новая категория",
            pathToIcon: "../icons/Expense/NewIcon.svg"
        };
        categoryModel.addCategory(newCategory);
    }
}
