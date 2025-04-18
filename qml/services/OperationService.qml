import QtQuick 2.0
import QtQuick.LocalStorage 2.0

QtObject {
    id: service

    function getDatabase() {
        return LocalStorage.openDatabaseSync("WebBudgetDB", "1.0", "WebBudget storage", 1000000)
    }

    function initialize() {
        var db = getDatabase()
        db.transaction(function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS operations (id INTEGER PRIMARY KEY AUTOINCREMENT, amount INTEGER, action INTEGER, category TEXT, date TEXT, desc TEXT)')
        })
    }

    function loadOperations() {
        var operations = []
        var db = getDatabase()
        db.readTransaction(function(tx) {
            var rs = tx.executeSql('SELECT * FROM operations ORDER BY id DESC')
            for (var i = 0; i < rs.rows.length; i++) {
                operations.push(rs.rows.item(i))
            }
        })
        return operations
    }

    function addOperation(operation) {
        var db = getDatabase()
        db.transaction(function(tx) {
            tx.executeSql('INSERT INTO operations (amount, action, category, date, desc) VALUES (?, ?, ?, ?, ?)', [
                operation.amount,
                operation.action,
                operation.category,
                operation.date,
                operation.desc
            ])
        })
    }
}
