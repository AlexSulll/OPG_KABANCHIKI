import QtQuick 2.0
import QtQuick.LocalStorage 2.0

QtObject {
    property string databaseName: "WebBudgetDB"

    function getDatabase() {
        return LocalStorage.openDatabaseSync(databaseName, "1.0", "Category DB", 100000);
    }

    function initialize() {
        var db = getDatabase();
        db.transaction(function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS categories (id INTEGER PRIMARY KEY AUTOINCREMENT, nameCategory TEXT, typeCategory TEXT, pathToIcon TEXT)');
        });
    }

    function addCategory(nameCategory, typeCategory, pathToIcon) {
        var db = getDatabase();
        db.transaction(function(tx) {
            tx.executeSql('INSERT INTO categories (nameCategory, typeCategory, pathToIcon) VALUES (?, ?, ?)',
                          [nameCategory, typeCategory, pathToIcon]);
        });
    }

    function getCategoriesByType(typeCategory) {
        var db = getDatabase();
        var results = [];
        db.readTransaction(function(tx) {
            var rs = tx.executeSql('SELECT * FROM categories WHERE typeCategory = ?', [typeCategory]);
            for (var i = 0; i < rs.rows.length; i++) {
                results.push(rs.rows.item(i));
            }
        });
        return results;
    }

    Component.onCompleted: initialize()
}
