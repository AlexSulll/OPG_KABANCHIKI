/*
  Изменено:
    а) id - зарезервированное слово -> categoryId
    б) нейросетка дала функцию, необходимую для обработки
    в) Закинула статик массив для тестирования отображения
        categoryId=0 - кнопка добавления новой категории
        (+одна иконка в начале твоих папок иконок - в 2х сразу)
*/
import QtQuick 2.0
import Sailfish.Silica 1.0

QtObject {
    objectName: "CategoryModel"

    property var categories: []

    // Инициализация с тестовыми данными
    Component.onCompleted: {
        categories = [
            {categoryId: 0, nameCategory: "Добавить", pathToIcon: "../icons/Expense/addIcon.svg"},
            {categoryId: 1, nameCategory: "Магазины", pathToIcon: "../icons/Expense/CafeIcon.svg"},
            {categoryId: 2, nameCategory: "Образование", pathToIcon: "../icons/Expense/EducationIcon.svg"}
        ];
    }

    // Загрузка данных из JSON
    function loadFromJson(jsonData) {
        try {
            categories = JSON.parse(jsonData);
            return true;
        } catch(e) {
            console.error("Error parsing JSON:", e);
            return false;
        }
    }

    // Добавление новой категории
    function addCategory(category) {
        categories.push(category);
    }
}
