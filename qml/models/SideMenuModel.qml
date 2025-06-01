import QtQuick 2.0

ListModel {

    ListElement {
        text: "Главная"
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

    ListElement {
        text: "Цели"
        icon: "icon-m-whereami"
        page: "../pages/GoalsPage.qml"
    }

    ListElement {
        text: "Лимиты категорий"
        icon: "icon-m-warning"
        page: "../pages/LimitCategoryPage.qml"
    }

    ListElement {
        text: "Регулярные платежи"
        icon: "icon-m-sync"
        page: "../pages/RegularOperationPage.qml"
    }

    ListElement {
        text: "О программе"
        icon: "icon-m-about"
        page: "../pages/AboutPage.qml"     // заглушка - не указан точный путь
    }
}
