import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"
import "../services" as Services
import "../models" as Models

BasePage {
    id: mainpage
    property string selectedTab: "expenses"

    // Экземпляр сервиса
    Services.CategoryService {
        id: categoryService
        Component.onCompleted: initialize()
    }

    HeaderComponent {
        id: header
        headerText: "Баланс"
        selectedTab: parent.selectedTab
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
}
