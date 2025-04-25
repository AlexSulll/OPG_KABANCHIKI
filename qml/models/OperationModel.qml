import QtQuick 2.0
import "../services" as Services

ListModel {
    id: operationModel
    objectName: "OperationModel"
    property real totalBalance: 0
    property var data: []
    property var service: Services.OperationService {
        id: internalService
        Component.onCompleted: {
            initialize();
            operationModel.refresh();
        }
    }

    function add(operation) {
        service.addOperation(operation);
        refresh();
    }

    function calculateTotalBalance() {
        var income = service.getTotalIncome();
        var expenses = service.getTotalExpenses();
        totalBalance = income - expenses;
        return totalBalance;
    }

    function refresh() {
        if (service) {
            var ops = service.loadOperations();
            if (ops && ops.length > 0) {
                loadOperation(ops);
            } else {
                console.error("Не удалось загрузить операции");
            }
        } else {
            console.error("Сервис операций не инициализирован");
        }
    }

    function loadByTypeOperation(type, startDate, endDate) {
            loadOperation(service.getTotalSumByCategory(type, startDate, endDate))
    }

    function loadByTypeCategory(categoryId, action) {
        loadOperation(service.getOperationByCategory(categoryId, action))
    }

    function loadOperation(operations) {
        clear();
        console.log("Загружено операций:", operations.length);
        if (operations) {
            operations.forEach(function(op) {
                append({
                    id: op.id,
                    amount: op.amount,
                    action: op.action,
                    categoryId: op.categoryId,
                    date: op.date,
                    desc: op.desc,
                    total: op.total || 0
                })
            })
        }
    }

    function getOperationById(id) {
        for (var i = 0; i < count; i++) {
            if (get(i).id === id) return get(i)
        }
        return null
    }

    function updateOperation(operation) {
        service.updateOperation(operation)
        refresh()
    }

    function deleteOperation(id) {
        service.deleteOperation(id)
        refresh()
    }

    function parseDate(dateStr) {
        var parts = dateStr.split(".");
        return parts.length === 3
            ? new Date(parts[2], parts[1]-1, parts[0])
            : new Date()
    }

    function loadByTypeOperationForCard(type) {
        data = service.getTotalSumByCategory(type);
        return data
    }

}
