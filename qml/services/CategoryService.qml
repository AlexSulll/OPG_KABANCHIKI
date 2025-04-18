import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0

QtObject {
    objectName: "categoryService"

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
                pathToIcon TEXT
            )');

            // Проверка на пустую таблицу и добавление тестовых данных
            var check = tx.executeSql('SELECT COUNT(*) as count FROM categories');
            if (check.rows.item(0).count === 0) {
                tx.executeSql('INSERT INTO categories (nameCategory, typeCategory, pathToIcon) VALUES ("Пусто", 0, "image://theme/icon-m-question")');
            }
        });
    }


    function loadCategories(typeCategory) {
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

    // Новый метод для удаления
    function dropCategories() {
        var db = getDatabase();
        db.transaction(function(tx) {
            tx.executeSql("DELETE FROM categories");
            tx.executeSql("DELETE FROM sqlite_sequence WHERE name='categories'");
        });
        console.log("Все категории удалены");
    }
}
