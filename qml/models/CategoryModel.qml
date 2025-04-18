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
import "../services" as Services

ListModel {
    id: categoryModel
    objectName: "CategoryModel"

    property var categories: []

    Services.CategoryService {
            id: categoryService
    }

    // Инициализация с тестовыми данными

    function loadCategoriesByType(typeCategory) {
            Services.categoryService.initialize()
            categories = Services.categoryService.loadCategories(typeCategory)
    }

    function addCategory(category) {
            Services.categoryService.addCategory(category)
            loadCategoriesByType(category.typeCategory)  // Перезагружаем
    }
}
