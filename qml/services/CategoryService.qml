import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import "../icons/Expense/"

QtObject {

    objectName: "categoryService"

    Component.onCompleted: initialize()

    function getDatabase() {
        return LocalStorage.openDatabaseSync("WebBudgetDB", "1.0", "WebBudget storage", 1000000);
    }

    function initialize() {
        var db = getDatabase();

        db.transaction(function (tx) {
            tx.executeSql("CREATE TABLE IF NOT EXISTS categories (
                categoryId INTEGER PRIMARY KEY AUTOINCREMENT,
                nameCategory TEXT,
                typeCategory INTEGER,
                pathToIcon TEXT,
                limitAmount INTEGER DEFAULT 0,
                isActive BOOLEAN DEFAULT 1
            )");

            var check = tx.executeSql("SELECT COUNT(*) as count FROM categories");

            if (check.rows.item(0).count === 0) {
                tx.executeSql('INSERT INTO categories (nameCategory, typeCategory, pathToIcon) VALUES ("Кафе", 0, "../icons/Expense/CafeIcon.svg")');
                tx.executeSql('INSERT INTO categories (nameCategory, typeCategory, pathToIcon) VALUES ("Досуг", 0, "../icons/Expense/FreeTimeIcon.svg")');
                tx.executeSql('INSERT INTO categories (nameCategory, typeCategory, pathToIcon) VALUES ("Образование", 0, "../icons/Expense/EducationIcon.svg")');
                tx.executeSql('INSERT INTO categories (nameCategory, typeCategory, pathToIcon) VALUES ("Подарки", 0, "../icons/Expense/GiftIcon.svg")');
                tx.executeSql('INSERT INTO categories (nameCategory, typeCategory, pathToIcon) VALUES ("Дом", 0, "../icons/Expense/HouseIcon.svg")');
                tx.executeSql('INSERT INTO categories (nameCategory, typeCategory, pathToIcon) VALUES ("Продукты", 0, "../icons/Expense/ProductsIcon.svg")');
                tx.executeSql('INSERT INTO categories (nameCategory, typeCategory, pathToIcon) VALUES ("Здоровье", 0, "../icons/Expense/HealthIcon.svg")');
                tx.executeSql('INSERT INTO categories (nameCategory, typeCategory, pathToIcon) VALUES ("Добавить", 0, "../icons/Expense/addIcon.svg")');
                tx.executeSql('INSERT INTO categories (nameCategory, typeCategory, pathToIcon) VALUES ("Зарплата", 1, "../icons/Revenue/SalaryIcon.svg")');
                tx.executeSql('INSERT INTO categories (nameCategory, typeCategory, pathToIcon) VALUES ("Проценты по вкладу", 1, "../icons/Revenue/BankIcon.svg")');
                tx.executeSql('INSERT INTO categories (nameCategory, typeCategory, pathToIcon) VALUES ("Подарок", 1, "../icons/Expense/GiftIcon.svg")');
                tx.executeSql('INSERT INTO categories (nameCategory, typeCategory, pathToIcon) VALUES ("Другое", 1, "../icons/Revenue/OtherIcon.svg")');
                tx.executeSql('INSERT INTO categories (nameCategory, typeCategory, pathToIcon) VALUES ("Добавить", 1, "../icons/Expense/addIcon.svg")');
            }
        });
    }

    function loadCategories(typeCategory) {
        var db = getDatabase();
        var result = [];

        db.readTransaction(function (tx) {
            var rs = tx.executeSql("SELECT c.categoryId AS categoryId, c.nameCategory, c.typeCategory, c.pathToIcon FROM categories c WHERE isActive = 1 AND c.typeCategory = ? ORDER BY categoryId", [typeCategory]);

            for (var i = 0; i < rs.rows.length; ++i) {
                result.push(rs.rows.item(i));
            }
        });

        return result;
    }

    function loadCategoriesWithGoals(typeCategory) {
        var db = getDatabase();
        var result = [];
        db.readTransaction(function (tx) {
            var rs = tx.executeSql("SELECT * FROM categories WHERE typeCategory = ? ORDER BY categoryId", [typeCategory]);

            for (var i = 0; i < rs.rows.length; ++i) {
                result.push(rs.rows.item(i));
            }
        });

        return result;
    }

    function addCategory(category) {
        var db = getDatabase();

        db.transaction(function (tx) {
            tx.executeSql("INSERT INTO categories (nameCategory, typeCategory, pathToIcon) VALUES (?, ?, ?)", [category.nameCategory, category.typeCategory, category.pathToIcon]);
        });
    }

    function loadCategoriesByCategoryId(categoryId) {
        var db = getDatabase();
        var result = [];

        db.readTransaction(function (tx) {
            var rs = tx.executeSql("SELECT * FROM categories WHERE categoryId = ?", [categoryId]);
            for (var i = 0; i < rs.rows.length; ++i) {
                result.push(rs.rows.item(i));
            }
        });

        return result;
    }

    function updateCategory(updatedCategory) {
        if (!updatedCategory || !updatedCategory.categoryId) {
            console.error("Invalid category data or missing categoryId");
            return false;
        }

        var db = getDatabase();
        var result = false;

        db.transaction(function (tx) {
            try {
                var query = "UPDATE categories SET " + "nameCategory = ?, " + "typeCategory = ?, " + "pathToIcon = ? " + "WHERE categoryId = ?";

                var res = tx.executeSql(query, [updatedCategory.nameCategory, updatedCategory.typeCategory, updatedCategory.pathToIcon, updatedCategory.categoryId]);

                result = res.rowsAffected > 0;

                if (result) {
                    console.log("Category updated successfully:", updatedCategory.categoryId);
                } else {
                    console.warn("No rows affected, category may not exist:", updatedCategory.categoryId);
                }
            } catch (err) {
                console.error("Error updating category:", err);
                result = false;
            }
        });

        if (result) {
            for (var i = 0; i < categories.length; i++) {
                if (categories[i].categoryId === updatedCategory.categoryId) {
                    categories[i] = updatedCategory;
                    break;
                }
            }
        }

        return result;
    }

    function setCategoryLimit(categoryId, limit) {
        var db = getDatabase();

        db.transaction(function (tx) {
            tx.executeSql("UPDATE categories SET limitAmount = ? WHERE categoryId = ?", [limit, categoryId]);
        });
    }

    function getCategoryLimit(categoryId) {
        var db = getDatabase();
        var limit = null;

        db.readTransaction(function (tx) {
            var rs = tx.executeSql("SELECT limitAmount FROM categories WHERE categoryId = ?", [categoryId]);

            if (rs.rows.length > 0) {
                limit = rs.rows.item(0).limitAmount;
            }
        });

        return limit;
    }

    function removeCategoryLimit(categoryId) {
        var db = getDatabase();

        db.transaction(function (tx) {
            tx.executeSql("UPDATE categories SET limitAmount = 0 WHERE categoryId = ?", [categoryId]);
        });
    }

    function removeCategory(categoryId) {
        if (!categoryId) {
            console.error("Invalid categoryId");
            return false;
        }

        var db = getDatabase();
        var result = false;

        db.transaction(function (tx) {
            try {
                var updateQuery = "UPDATE operations SET categoryId = NULL WHERE categoryId = ?";
                tx.executeSql(updateQuery, [categoryId]);
                var deleteQuery = "DELETE FROM categories WHERE categoryId = ?";
                var res = tx.executeSql(deleteQuery, [categoryId]);

                result = res.rowsAffected > 0;

                if (result) {
                    console.log("Category deleted successfully:", categoryId);
                } else {
                    console.warn("No rows affected, category may not exist:", categoryId);
                }
            } catch (err) {
                console.error("Error deleting category:", err);
                result = false;
            }
        });

        if (result) {
            for (var i = 0; i < categories.length; i++) {
                if (categories[i].categoryId === categoryId) {
                    categories.splice(i, 1);
                    break;
                }
            }
        }

        return result;
    }
}
