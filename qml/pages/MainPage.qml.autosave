import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"
import "../services" as Services
import "../models" as Models

BasePage {
    id: mainpage
    objectName: "MainPage"

    property string selectedTab: "expenses"

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

    HeaderComponent {
        id: header
        headerText: "Баланс"
        selectedTab: mainpage.selectedTab
        onSelectedTabChanged: {
                mainpage.selectedTab = header.selectedTab; // Обновляем родителя
                console.log("Выбран таб:", header.selectedTab);
       }
    }

    SilicaListView {
            anchors.fill: parent
            model: operationModel

            delegate: ListItem {
                width: parent.width
                contentHeight: Theme.itemSizeMedium

                Label {
                    text: "Сумма: " + model.amount + " ₽ | Категория: " + model.category
                    anchors.centerIn: parent
                }
            }
    }

    Button {
        anchors.centerIn: parent
        text: "Обновить"
        onClicked: operationModel.refresh()
    }

    // Кнопка удаления
    Button {
        text: "Удалить все категории"
        anchors.centerIn: parent
        color: "red"
        onClicked: {
            categoryService.dropCategories(); // Вызов метода через локальный id
            console.log("Категории удалены");
        }
    }

    function refreshOperations() {
            operationModel.refresh();
    }
}
