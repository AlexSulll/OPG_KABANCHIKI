import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"
import "../services" as Services
import "../models" as Models

BasePage {
    id: mainpage
    objectName: "MainPage"

    property string selectedTab: "expenses"
    property var categoryModel: Models.CategoryModel {}

    // Экземпляр сервиса
    Services.CategoryService {
        id: categoryService
        Component.onCompleted: initialize()
    }

    Services.OperationService {
        id: operationService
        Component.onCompleted: initialize()
    }

    Models.OperationModel {
            id: operationModel
            service: operationService
    }

    Models.CategoryModel {
        id: categoryModel
        service: categoryService
        Component.onCompleted: {
            loadAllCategories();
        }
    }

    HeaderComponent {
        id: header
        headerText: "Баланс"
        selectedTab: mainpage.selectedTab
        operationModel: operationModel
        onSelectedTabChanged: {
                mainpage.selectedTab = header.selectedTab; // Обновляем родителя
                operationModel.loadByType(header.selectedTab === "expenses" ? 0 : 1)
       }
    }

    SilicaListView {
            anchors {
                top: header.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                margins: Theme.paddingMedium
            }
            model: operationModel
            spacing: Theme.paddingSmall
            clip: true

            delegate: ListItem {
                width: parent.width
                contentHeight: Theme.itemSizeMedium

                // Получаем данные о категории
                property var categoryData: {
                        var data = categoryModel.getCategoryById(model.categoryId);
                        return data;
               }

                Rectangle {
                    anchors.fill: parent
                    radius: Theme.paddingMedium
                    color: Theme.rgba("#24224f", 0.9)

                    Row {
                        anchors.fill: parent
                        anchors.margins: Theme.paddingMedium
                        spacing: Theme.paddingMedium

                        // Иконка категории
                        Image {
                            id:icon
                            asynchronous: true
                            width: Theme.iconSizeMedium
                            height: width
                            anchors.verticalCenter: parent.verticalCenter
                            source: categoryData ? categoryData.pathToIcon : ""
                            sourceSize: Qt.size(width, height)
                            fillMode: Image.PreserveAspectFit

                            // Добавляем отладочную информацию
                            onStatusChanged: {
                                if (status === Image.Ready) {
                                    console.log("Иконка загружена:", source,
                                               "\nРеальный размер:", implicitWidth + "x" + implicitHeight,
                                               "\nОтображаемый размер:", width + "x" + height);
                                }
                                if (status === Image.Error) {
                                    console.error("Ошибка загрузки иконки:", source);
                                }
                            }

                        }

                        // Название категории и дата
                        Column {
                            width: parent.width * 0.6
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: icon.right
                            anchors.leftMargin: Theme.paddingLarge
                            spacing: Theme.paddingSmall

                            Label {
                                text: categoryData ? categoryData.nameCategory : "Без категории"
                                color: Theme.primaryColor
                                font.pixelSize: Theme.fontSizeLarge
                                truncationMode: TruncationMode.Fade
                            }

                            Label {
                                text: Qt.formatDate(new Date(model.date), "dd.MM.yyyy")
                                color: Theme.secondaryColor
                                font.pixelSize: Theme.fontSizeExtraSmall
                            }
                        }

                        Label {
                            id: amountLabel
                            width: Math.min(implicitWidth, item.width * 0.35)
                            anchors {
                                verticalCenter: parent.verticalCenter
                                right: parent.right
                                rightMargin: Theme.paddingSmall
                            }
                            horizontalAlignment: Text.AlignRight
                            text: (model.action === 0 ? "-" : "+") + model.amount + " ₽"
                            color: model.action === 0 ? Theme.errorColor : Theme.highlightColor
                            font {
                                pixelSize: Theme.fontSizeLarge
                                family: Theme.fontFamilyHeading
                                bold: true
                            }
                            elide: Text.ElideRight
                        }
                    }
                }
            }

            VerticalScrollDecorator {}
        }

// Не работает TODO
//    Button {
//        anchors.horizontalCenter: parent.horizontalCenter
//        anchors.bottom: parent.bottom
//        anchors.centerIn: parent
//        color: "blue"
//        text: "Обновить"
//        onClicked: {
//            operationModel.refresh();
//            console.log(JSON.stringify(operationModel));
//            console.log(JSON.stringify(operationModel.load()));
//            console.log("Категорий в модели:", categoryModel.count);
//            console.log("Операций в модели:", operationModel.count);
//        }
//    }

    Button {
        text: "Проверить модели"
        onClicked: {
            console.log("=== Категории ===");
            for (var i = 0; i < categoryModel.count; i++) {
                var cat = categoryModel.get(i);
                console.log("ID:", cat.categoryId, "Название:", cat.nameCategory);
            }

            console.log("=== Операции ===");
            for (var j = 0; j < operationModel.count; j++) {
                var op = operationModel.get(j);
                console.log("ID категории:", op.categoryId, "Сумма:", op.amount);
            }
        }
    }


    // Кнопка удаления
//    Button {
//        text: "Удалить все категории"
//        anchors.centerIn: parent
//        color: "red"
//        onClicked: {
//            categoryService.dropCategories(); // Вызов метода через локальный id
//            console.log("Категории удалены");
//        }
//    }

    function refreshOperations() {
            operationModel.refresh();
    }
}
