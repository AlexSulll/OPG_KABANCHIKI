import QtQuick 2.0
import QtQuick.LocalStorage 2.0

QtObject {
    id: service

    Component.onCompleted: initialize()

    function getDatabase() {
        return LocalStorage.openDatabaseSync("WebBudgetDB", "1.0", "WebBudget storage", 1000000)
    }

    function initialize() {
        var db = getDatabase()
        db.transaction(function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS operations (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                amount INTEGER,
                action INTEGER,
                categoryId INTEGER,
                date TEXT,
                desc TEXT
            )');
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
            tx.executeSql('INSERT INTO operations (amount, action, categoryId, date, desc) VALUES (?, ?, ?, ?, ?)', [
                operation.amount,
                operation.action,
                operation.categoryId,
                operation.date,
                operation.desc
            ])
        })
    }

    function deleteOperation(operationId) {
        var db = getDatabase()
        db.transaction(function(tx) {
            tx.executeSql('DELETE FROM operations WHERE id = ?', [operationId])
        })
    }

    // В OperationService.qml
    function getTotalSumByCategory(type) {
        var db = getDatabase()
        var categories = []
        db.readTransaction(function(tx) {
            var rs = tx.executeSql(
                        'SELECT
                            operations.action,
                            operations.categoryId,
                            operations.date,
                            operations.desc,
                            SUM(operations.amount) as total
                        FROM operations
                        JOIN categories
                            ON categories.categoryId = operations.categoryId AND operations.action = ?
                        GROUP BY categories.categoryId
                        ORDER BY total DESC', [type])
            for (var i = 0; i < rs.rows.length; i++) {
                var item = rs.rows.item(i)
                categories.push({
                    categoryId: item.categoryId,
                    name: item.nameCategory,
                    icon: item.pathToIcon,
                    total: item.total
                })
            }
        })
        return categories
    }
}
