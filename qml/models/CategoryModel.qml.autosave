import QtQuick 2.0
import Sailfish.Silica 1.0
import "../services" as Services

ListModel {
    id: categoryModel
    objectName: "CategoryModel"


    // Сервис для работы с данными
    property var service: Services.CategoryService {
        id: categoryService
        Component.onCompleted: initialize()
    }

    // Динамический список категорий
    property var categories: []

    // Загрузка категорий по типу
    function loadCategoriesByType(type) {
        categories = service.loadCategories(type);
        updateModel();
    }

    // Обновление ListModel
    function updateModel() {
        clear();
        for (var i = 0; i < categories.length; i++) {
            append({
                categoryId: categories[i].categoryId,
                nameCategory: categories[i].nameCategory,
                pathToIcon: categories[i].pathToIcon,
                typeCategory: categories[i].typeCategory
            });
        }
    }

    // Добавление новой категории
    function addCategory(category) {
        service.addCategory(category);
        loadCategoriesByType(category.typeCategory);
    }

    function getCategoryById(categoryId) {
        for (var i = 0; i < categories.length; i++) {
            if (categories[i].categoryId === categoryId) {
                return {
                    categoryId: categories[i].categoryId,
                    nameCategory: categories[i].nameCategory,
                    pathToIcon: categories[i].pathToIcon,
                    typeCategory: categories[i].typeCategory
                }
            }
        }
        return null
    }
}
