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
                FOREIGN KEY(categoryId) REFERENCES categories(id)
            )");
        });
    }

    function addPayment(payment) {
        var db = getDatabase();
        var result = false;

        db.transaction(function(tx) {
            var res = tx.executeSql(
                "INSERT INTO regular_payments (amount, categoryId, frequency, description, isIncome, nextPaymentDate)
                VALUES (?, ?, ?, ?, ?, ?)",
                [
                    payment.amount,
                    payment.categoryId,
                    payment.frequency,
                    payment.description,
                    payment.isIncome,
                    payment.nextPaymentDate
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

    function updatePayment(payment) {
        var db = getDatabase();
        var result = false;

        db.transaction(function(tx) {
            var res = tx.executeSql(
                "UPDATE regular_payments SET
                    nextPaymentDate = ?
                WHERE id = ?",
                [payment.nextPaymentDate, payment.id]
            );
            result = res.rowsAffected > 0;
        });

        return result;
    }

    function getPayments() {
        var payments = [];
        var db = getDatabase();

        db.readTransaction(function(tx) {
            var rs = tx.executeSql(
                "SELECT rp.*, c.nameCategory as categoryName
                FROM regular_payments rp
                LEFT JOIN categories c ON rp.categoryId = c.categoryId
                ORDER BY nextPaymentDate ASC"
            );

            for (var i = 0; i < rs.rows.length; i++) {
                payments.push(rs.rows.item(i));
            }
        });

        return payments;
    }
}
