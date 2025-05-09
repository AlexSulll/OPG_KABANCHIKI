import QtQuick 2.0
import QtQuick.LocalStorage 2.0

QtObject {
    Component.onCompleted: initialize()

    function getDatabase() {
        return LocalStorage.openDatabaseSync("WebBudgetDB", "1.0", "WebBudget storage", 1000000);
    }

    function initialize() {
        var db = getDatabase();
        db.transaction(function(tx) {
            tx.executeSql("CREATE TABLE IF NOT EXISTS regular_payments (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                amount REAL NOT NULL,
                categoryId INTEGER NOT NULL,
                frequency INTEGER NOT NULL,
                description TEXT,
                isIncome BOOLEAN DEFAULT 0,
                nextPaymentDate TEXT,
                lastProcessedDate TEXT,
                FOREIGN KEY(categoryId) REFERENCES categories(id)
            )");
        });
    }

    function addPayment(payment) {
        var db = getDatabase();
        var result = false;

        payment.nextPaymentDate = calculateNextDate(new Date(), payment.frequency);
        payment.lastProcessedDate = new Date().toISOString();

        db.transaction(function(tx) {
            var res = tx.executeSql(
                "INSERT INTO regular_payments (amount, categoryId, frequency, description, isIncome, nextPaymentDate, lastProcessedDate) VALUES (?, ?, ?, ?, ?, ?, ?)",
                [
                    payment.amount,
                    payment.categoryId,
                    payment.frequency,
                    payment.description,
                    payment.isIncome,
                    payment.nextPaymentDate,
                    payment.lastProcessedDate
                ]
            );
            result = res.rowsAffected > 0;
        });

        return result;
    }

    function removePayment(id) {
        var db = getDatabase();
        var result = false;

        db.transaction(function(tx) {
            var res = tx.executeSql("DELETE FROM regular_payments WHERE id = ?", [id]);
            result = res.rowsAffected > 0;
        });

        return result;
    }

    function getPayments() {
        var payments = [];
        var db = getDatabase();

        db.readTransaction(function(tx) {
            var rs = tx.executeSql("SELECT * FROM regular_payments");
            for (var i = 0; i < rs.rows.length; i++) {
                payments.push(rs.rows.item(i));
            }
        });

        return payments;
    }

    function updatePayment(payment) {
        var db = getDatabase();
        var result = false;

        db.transaction(function(tx) {
            var res = tx.executeSql(
                "UPDATE regular_payments SET nextPaymentDate = ?, lastProcessedDate = ? WHERE id = ?",
                [payment.nextPaymentDate, payment.lastProcessedDate, payment.id]
            );
            result = res.rowsAffected > 0;
        });

        return result;
    }

    function calculateNextDate(fromDate, frequency) {
        var date = new Date(fromDate);
        switch(frequency) {
            case 0: date.setDate(date.getDate() + 1); break // День
            case 1: date.setDate(date.getDate() + 7); break // Неделя
            case 2: date.setDate(date.getDate() + 14); break // 2 недели
            case 3: date.setMonth(date.getMonth() + 1); break // Месяц
            case 4: date.setMonth(date.getMonth() + 2); break // 2 месяца
            case 5: date.setMonth(date.getMonth() + 3); break // Квартал
            case 6: date.setMonth(date.getMonth() + 6); break // Полгода
            case 7: date.setFullYear(date.getFullYear() + 1); break // Год
        }
        return date.toISOString()
    }
}
