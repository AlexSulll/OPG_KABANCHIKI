import QtQuick 2.0
import QtQuick.LocalStorage 2.0

QtObject {

    function getDatabase() {
        return LocalStorage.openDatabaseSync("WebBudgetDB", "1.0", "WebBudget storage", 1000000)
    }

    function initialize() {
        var db = getDatabase()
        db.transaction(function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS goals (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                categoryId INTEGER,
                title TEXT,
                targetAmount REAL,
                currentAmount REAL,
                startDate TEXT,
                endDate TEXT,
                FOREIGN KEY(categoryId) REFERENCES categories(categoryId)
            )')
        })
    }

    function addGoal(goal) {
        var db = getDatabase()
        var categoryId = -1

        // Создаем категорию и получаем ее ID
        db.transaction(function(tx) {
            tx.executeSql(
                "INSERT INTO categories (nameCategory, typeCategory, pathToIcon) VALUES (?, ?, ?)",
                [goal.title, 0, "../icons/Expense/GoalsIcon.svg"]
            )
            var res = tx.executeSql("SELECT last_insert_rowid() as id")
            categoryId = res.rows.item(0).id
        })

        // Создаем цель с привязкой к категории
        db.transaction(function(tx) {
            tx.executeSql(
                'INSERT INTO goals (categoryId, title, targetAmount, currentAmount, startDate, endDate)
                VALUES (?, ?, ?, ?, ?, ?)',
                [categoryId, goal.title, goal.targetAmount, goal.currentAmount, goal.startDate, goal.endDate]
            )
        })
    }

    function updateGoal(goal) {
        var db = getDatabase()
        db.transaction(function(tx) {
            tx.executeSql('UPDATE goals SET
                title = ?,
                targetAmount = ?,
                currentAmount = ?,
                endDate = ?
                WHERE id = ?',
                [goal.title, goal.targetAmount, goal.currentAmount, goal.endDate, goal.id])
        })
    }

//    function updateCurrentAmount(goal) {
//        var db = getDatabase()
//        db.readTransaction(function(tx) {
//            var rs = tx.executeSql('SELECT currentAmount FROM goals WHERE id = ?', [goal.id])
//        })
//    }

    function getGoals() {
        var goals = []
        var db = getDatabase()
        db.readTransaction(function(tx) {
            var rs = tx.executeSql('SELECT * FROM goals ORDER BY endDate ASC')
            for(var i = 0; i < rs.rows.length; i++) {
                goals.push(rs.rows.item(i))
            }
        })
        return goals
    }
}
