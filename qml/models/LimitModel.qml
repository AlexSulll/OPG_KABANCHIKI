import QtQuick 2.0
import "../services" as Services

QtObject {
    id: limitModel

    property var categoryService: Services.CategoryService {
        id: categoryService
    }

    function setLimit(categoryId, amount) {
        categoryService.setCategoryLimit(categoryId, amount);
    }

    function getLimit(categoryId) {
        var limit = categoryService.getCategoryLimit(categoryId);
        return (limit === null || limit === undefined) ? 0 : limit;
    }

    function removeLimit(categoryId) {
        categoryService.removeCategoryLimit(categoryId);
    }

    function hasLimit(categoryId) {
        var limit = getLimit(categoryId);
        return limit !== null && limit !== undefined;
    }
}
