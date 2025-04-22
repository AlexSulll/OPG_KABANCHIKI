import QtQuick 2.0

ListModel {
    ListElement {
        text: "Записи"
        icon: "icon-m-home"
        page: "../pages/MainPage.qml"
    }
    ListElement {
        text: "Добавить"
        icon: "icon-splus-add"
        page: "../pages/OperationPage.qml"
    }
    ListElement {
        text: "Категории"
        icon: "icon-m-edit"
        page: "../pages/CategoryPage.qml"
    }
    // заглушка - не указан точный путь
    ListElement {
        text: "О программе"
        icon: "icon-m-about"
        page: "MainPage.qml"
    }
}
