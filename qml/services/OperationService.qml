import QtQuick 2.0
import QtQuick.LocalStorage 2.0
import "../components"

QtObject {
    id: service

    Component.onCompleted: initialize()

    property var range: []
    property string currentPeriod: "All"

    function getDatabase() {
        return LocalStorage.openDatabaseSync("WebBudgetDB", "1.0", "WebBudget storage", 1000000);
    }

    function initialize() {
        var db = getDatabase();
        db.transaction(function (tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS operations (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                amount INTEGER,
                action INTEGER,
                categoryId INTEGER,
                date TEXT,
                desc TEXT
            )');
        });
    }

    function loadOperations() {
        var operations = [];
        var db = getDatabase();
        db.readTransaction(function (tx) {
            var rs = tx.executeSql('SELECT * FROM operations ORDER BY id DESC');
            for (var i = 0; i < rs.rows.length; i++) {
                operations.push(rs.rows.item(i));
            }
        });
        return operations;
    }

    function loadExpOperations() {
        var operations = [];
        var db = getDatabase();
        db.readTransaction(function (tx) {
            var rs = tx.executeSql('SELECT * FROM operations WHERE action = 0 ORDER BY id DESC');
            for (var i = 0; i < rs.rows.length; i++) {
                operations.push(rs.rows.item(i));
            }
        });
        return operations;
    }

    function addOperation(operation) {
        var db = getDatabase();
        db.transaction(function (tx) {
            var goalResult = tx.executeSql("SELECT * FROM goals WHERE categoryId = ? AND isCompleted = 0", [operation.categoryId]);

            if (goalResult.rows.length > 0) {
                var goal = goalResult.rows.item(0);
                var remaining = goal.targetAmount - goal.currentAmount;
                operation.amount = Math.min(operation.amount, remaining);
                tx.executeSql("UPDATE goals SET currentAmount = currentAmount + ? WHERE id = ?", [operation.amount, goal.id]);
                var newAmount = goal.currentAmount + operation.amount;
                if (newAmount >= goal.targetAmount) {
                    tx.executeSql("UPDATE goals SET isCompleted = 1 WHERE id = ?", [goal.id]);
                    tx.executeSql("UPDATE categories SET isActive = 0 WHERE categoryId = ?", [operation.categoryId]);
                }
            }
            tx.executeSql('INSERT INTO operations (amount, action, categoryId, date, desc) VALUES (?, ?, ?, ?, ?)', [operation.amount, operation.action, operation.categoryId, operation.date, operation.desc]);
        });
    }

    function deleteOperation(operationId) {
        var db = getDatabase();
        db.transaction(function (tx) {
            var op = tx.executeSql("SELECT * FROM operations WHERE id = ?", [operationId]).rows.item(0);
            var goals = tx.executeSql("SELECT * FROM goals WHERE categoryId = ?", [op.categoryId]).rows;
            for (var i = 0; i < goals.length; i++) {
                var goal = goals.item(i);
                var newAmount = goal.currentAmount - op.amount;

                tx.executeSql("UPDATE goals SET currentAmount = ? WHERE id = ?", [newAmount, goal.id]);
                if (newAmount < goal.targetAmount && goal.isCompleted) {
                    tx.executeSql("UPDATE categories SET isActive = 1 WHERE categoryId = ?", [op.categoryId]);
                    tx.executeSql("UPDATE goals SET isCompleted = 0 WHERE id = ?", [goal.id]);
                }
            }
            tx.executeSql("DELETE FROM operations WHERE id = ?", [operationId]);
        });
    }

    function getTotalSumByCategory(type) {
        var db = getDatabase();
        var categories = [];
        db.readTransaction(function (tx) {
            var rs = tx.executeSql('SELECT
                            operations.action,
                            operations.categoryId,
                            operations.date,
                            operations.desc,
                            SUM(operations.amount) as total,
                            categories.nameCategory as nameCategory
                        FROM operations
                        JOIN categories
                            ON categories.categoryId = operations.categoryId AND operations.action = ?
                        GROUP BY categories.categoryId
                        ORDER BY total DESC', [type]);
            for (var i = 0; i < rs.rows.length; i++) {
                var item = rs.rows.item(i);
                categories.push({
                    categoryId: item.categoryId,
                    name: item.nameCategory,
                    icon: item.pathToIcon,
                    total: item.total,
                    date: item.date
                });
            }
        });
        return categories;
    }

    function getOperationCountByCategory(type) {
        var db = getDatabase();
        var categories = [];

        db.readTransaction(function (tx) {
            var rs = tx.executeSql("SELECT
                    categories.nameCategory as name,
                    COUNT(operations.id) as operationCount
                FROM operations
                JOIN categories
                    ON categories.categoryId = operations.categoryId AND operations.action = ?
                GROUP BY categories.categoryId
                ORDER BY operationCount DESC", [type]);

            for (var i = 0; i < rs.rows.length; i++) {
                var item = rs.rows.item(i);
                categories.push({
                    name: item.name,
                    operationCount: item.operationCount
                });
            }
        });

        return categories;
    }

    function getOperationByCategory(categoryId, type) {
        var db = getDatabase();
        var operations = [];
        db.readTransaction(function (tx) {
            var rs = tx.executeSql('SELECT * FROM operations WHERE categoryId = ? AND action = ? ORDER BY date DESC', [categoryId, type]);
            for (var i = 0; i < rs.rows.length; i++) {
                operations.push(rs.rows.item(i));
            }
        });
        return operations;
    }

    function getTotalIncome() {
        var total = 0;
        getDatabase().readTransaction(function (tx) {
            var rs = tx.executeSql('SELECT SUM(amount) as total FROM operations WHERE action = 1');
            total = rs.rows.item(0).total || 0;
        });
        return total;
    }

    function getTotalExpenses() {
        var total = 0;
        getDatabase().readTransaction(function (tx) {
            var rs = tx.executeSql('SELECT SUM(amount) as total FROM operations WHERE action = 0');
            total = rs.rows.item(0).total || 0;
        });
        return total;
    }

    function updateOperation(operation) {
        var db = getDatabase();
        db.transaction(function (tx) {
            tx.executeSql('UPDATE operations SET amount = ?, action = ?, categoryId = ?, date = ?, desc = ? WHERE id = ?', [operation.amount, operation.action, operation.categoryId, operation.date, operation.desc, operation.id]);
        });
    }

    function getFilteredCategories(type, period) {
        var db = getDatabase();
        var categories = [];
        currentPeriod = period;
        var range = dateFilter.getDateRange(currentPeriod);
        console.log("Filter range from:", range.fromDate, "to:", range.toDate);

        if (period === "All") {
            return getTotalSumByCategory(type);
        }

        db.readTransaction(function (tx) {
            var fromDateStr = Qt.formatDateTime(range.fromDate, "dd-MM-yyyy");
            var toDateStr = Qt.formatDateTime(range.toDate, "dd-MM-yyyy");

            console.log("Using dates for SQL:", fromDateStr, toDateStr);

            var query = 'SELECT operations.action, operations.categoryId, ' + 'SUM(operations.amount) as total, categories.nameCategory as nameCategory ' + 'FROM operations ' + 'JOIN categories ON categories.categoryId = operations.categoryId ' + 'WHERE operations.action = ? ' + 'AND (substr(date, 7, 4) || "-" || substr(date, 4, 2) || "-" || substr(date, 1, 2)) ' + 'BETWEEN ? AND ? ' + 'GROUP BY operations.categoryId ORDER BY total DESC';
            var sqlFromDate = Qt.formatDateTime(range.fromDate, "yyyy-MM-dd");
            var sqlToDate = Qt.formatDateTime(range.toDate, "yyyy-MM-dd");

            var rs = tx.executeSql(query, [type, sqlFromDate, sqlToDate]);
            console.log("Executed query:", query, "with params:", [type, sqlFromDate, sqlToDate]);
            console.log("Found rows:", rs.rows.length);

            for (var i = 0; i < rs.rows.length; i++) {
                var item = rs.rows.item(i);
                categories.push({
                    categoryId: item.categoryId,
                    categoryName: item.nameCategory,
                    total: item.total || 0,
                    action: item.action
                });
            }
        });
        console.log("Returning categories:", JSON.stringify(categories));

        return categories;
    }

    function getOperationsByCategoryAndPeriod(categoryId, type, period, dateRange) {
        var db = getDatabase();
        var operations = [];
        var fromDateSQL = dateRange ? dateRange.fromDate : null;
        var toDateSQL = dateRange ? dateRange.toDate : null;

        console.log("Fetching operations for category:", categoryId, "type:", type, "period:", period, "range:", fromDateSQL, toDateSQL);

        db.readTransaction(function (tx) {
            var query = 'SELECT * FROM operations WHERE categoryId = ? AND action = ?';
            var params = [categoryId, type];

            if (period !== "All" && fromDateSQL && toDateSQL) {
                query += ' AND substr(date, 7, 4) || "-" || substr(date, 4, 2) || "-" || substr(date, 1, 2) BETWEEN ? AND ?';
                params.push(fromDateSQL);
                params.push(toDateSQL);
                console.log("SQL Query:", query);
                console.log("SQL Params:", params);
            } else {
                console.log("SQL Query:", query);
                console.log("SQL Params:", params);
            }
            query += ' ORDER BY date ASC';

            var rs = tx.executeSql(query, params);
            for (var i = 0; i < rs.rows.length; i++) {
                operations.push(rs.rows.item(i));
            }
            console.log("Found operations:", JSON.stringify(operations));
        });
        return operations;
    }

    function getOperationsByPeriod(period) {
        var db = getDatabase();
        var operations = [];

        db.readTransaction(function (tx) {
            var query = 'SELECT * FROM operations';
            var params = [];

            if (period && period !== "All") {
                var dateRange = getDateRange(period);
                query += ' WHERE date BETWEEN ? AND ?';
                params.push(Qt.formatDate(dateRange.fromDate, "dd.MM.yyyy"));
                params.push(Qt.formatDate(dateRange.toDate, "dd.MM.yyyy"));
            }

            query += ' ORDER BY date ASC';

            var rs = tx.executeSql(query, params);
            for (var i = 0; i < rs.rows.length; i++) {
                operations.push(rs.rows.item(i));
            }
        });

        console.log("Loaded operations:", operations.length, "for period:", period);
        return operations;
    }

    function getDateRange(period) {
        var now = new Date();
        var fromDate = new Date();
        var toDate = new Date();

        switch (period) {
        case "Week":
            fromDate.setDate(now.getDate() - 7);
            break;
        case "Month":
            fromDate.setMonth(now.getMonth() - 1);
            break;
        case "Year":
            fromDate.setFullYear(now.getFullYear() - 1);
            break;
        default:
            fromDate = new Date(0); // Начало эпохи Unix
            toDate = new Date(8640000000000000); // Максимальная дата
            break;
        }

        return {
            fromDate: fromDate,
            toDate: toDate
        };
    }

    function getExpensesByMonth(monthName) {
        var db = getDatabase();
        var categories = [];
        var currentYear = new Date().getFullYear().toString();
        var monthNumber = {
            "JAN": 1,
            "FEB": 2,
            "MAR": 3,
            "APR": 4,
            "MAY": 5,
            "JUN": 6,
            "JUL": 7,
            "AUG": 8,
            "SEP": 9,
            "OCT": 10,
            "NOV": 11,
            "DEC": 12
        }[monthName.toUpperCase()];

        if (!monthNumber) {
            console.error("Invalid month name:", monthName);
            return [];
        }

        db.readTransaction(function (tx) {
            var monthStr = monthNumber < 10 ? "0" + monthNumber : monthNumber.toString();
            var query = "SELECT " + "operations.categoryId, " + "categories.nameCategory as categoryName, " + "SUM(operations.amount) as totalExpenses " + "FROM operations " + "JOIN categories ON categories.categoryId = operations.categoryId " + "WHERE " + "operations.action = 0 AND " + "substr(date, 4, 2) = ? AND " +  // Month (positions 4-5)
            "substr(date, 7, 4) = ? " +     // Year (positions 7-10)
            "GROUP BY operations.categoryId " + "ORDER BY totalExpenses DESC";

            var rs = tx.executeSql(query, [monthStr, currentYear]);

            for (var i = 0; i < rs.rows.length; i++) {
                var item = rs.rows.item(i);
                categories.push({
                    categoryName: item.categoryName,
                    value: item.totalExpenses || 0
                });
            }
        });

        console.log("MonthCategory: ", JSON.stringify(categories));
        return categories;
    }

    function getOperationsForExport(params) {
        var operations = [];
        var db = getDatabase();

        db.transaction(function (tx) {
            var query = "SELECT * FROM operations WHERE 1=1";
            var args = [];
            if (params.type === 1) {
                query += " AND action = ?";
                args.push(1);
            } else if (params.type === 2) {
                query += " AND action = ?";
                args.push(0);
            }
            if (params.period !== 2) {
                var now = new Date();
                var startDate = new Date();

                if (params.period === 0) {
                    startDate.setMonth(now.getMonth() - 1);
                } else {
                    startDate.setMonth(now.getMonth() - 3);
                }
                var fromDate = Qt.formatDate(startDate, "dd.MM.yyyy");
                var toDate = Qt.formatDate(now, "dd.MM.yyyy");

                query += " AND date >= ? AND date <= ?";
                args.push(fromDate);
                args.push(toDate);
            }

            var rs = tx.executeSql(query, args);
            for (var i = 0; i < rs.rows.length; i++) {
                operations.push(rs.rows.item(i));
            }
        });

        return operations;
    }
}
