import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import "../icons/Expense/"

QtObject {
    objectName: "categoryService"

    Component.onCompleted: initialize()

    function getDatabase() {
        return LocalStorage.openDatabaseSync("WebBudgetDB", "1.0", "WebBudget storage", 1000000)
    }

    function initialize() {
        var db = getDatabase();
        db.transaction(function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS categories (
                categoryId INTEGER PRIMARY KEY AUTOINCREMENT,
                nameCategory TEXT,
                typeCategory INTEGER,
                pathToIcon TEXT,
                isActive BOOLEAN DEFAULT 1
            )');

            var check = tx.executeSql('SELECT COUNT(*) as count FROM categories');
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
        db.readTransaction(function(tx) {
            var rs = tx.executeSql("SELECT c.categoryId AS categoryId, c.nameCategory, c.typeCategory, c.pathToIcon
                                    FROM categories c
                                    LEFT JOIN goals g ON c.categoryId = g.categoryId
                                    WHERE (g.isCompleted IS NULL OR g.isCompleted = 0) AND typeCategory = ? ORDER BY categoryId", [typeCategory]);
            for (var i = 0; i < rs.rows.length; ++i) {
                result.push(rs.rows.item(i));
            }
        });
        return result;
    }

    function loadCategoriesWithGoals(typeCategory) {
        var db = getDatabase();
        var result = [];
        db.readTransaction(function(tx) {
            var rs = tx.executeSql("SELECT * FROM categories WHERE typeCategory = ? ORDER BY categoryId", [typeCategory]);
            for (var i = 0; i < rs.rows.length; ++i) {
                result.push(rs.rows.item(i));
            }
        });
        return result;
    }

    function addCategory(category) {
        var db = getDatabase();
        db.transaction(function(tx) {
            tx.executeSql("INSERT INTO categories (nameCategory, typeCategory, pathToIcon) VALUES (?, ?, ?)", [
                category.nameCategory,
                category.typeCategory,
                category.pathToIcon
            ]);
        });
    }

    function dropCategories() {
        var db = getDatabase();
        db.transaction(function(tx) {
            tx.executeSql("DELETE FROM categories");
            tx.executeSql("DELETE FROM sqlite_sequence WHERE name='categories'");
        });
    }

    function loadCategoriesByCategoryId(categoryId) {
        var db = getDatabase();
        var result = [];
        db.readTransaction(function(tx) {
            var rs = tx.executeSql("SELECT * FROM categories WHERE categoryId = ?", [categoryId]);
            for (var i = 0; i < rs.rows.length; ++i) {
                result.push(rs.rows.item(i));
            }
        });
        return result;
    }

    function updateCategory(categoryId, text) {
        var db = getDatabase();
        var result = false;
        db.transaction(function(tx) {
            var query = "UPDATE categories SET nameCategory = ? WHERE categoryId = ?";
            var res = tx.executeSql(query, [text, categoryId]);
            result = res.rowsAffected > 0;
        });

        if (!result) {
            console.warn("Failed to update category name");
            return false;
        }
    }
}
