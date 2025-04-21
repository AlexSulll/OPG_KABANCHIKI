/*
  OperationModel.qml
*/

import QtQuick 2.0
import "../services" as Services

ListModel {
    id: operationModel
    objectName: "OperationModel"

    property var service: Services.OperationService {
        id: internalService
        Component.onCompleted: {
            initialize();
            operationModel.refresh();
        }
    }

    function load(operations) {
        clear()
        if (operations) {
            operations.forEach(function(op) {
                append({
                    categoryId: op.categoryId,
                    name: op.name,
                    icon: op.icon,
                    total: op.total || 0 // Добавлено значение по умолчанию
                })
            })
        }
    }

    function add(operation) {
        console.log("Данные операции:", operation);
        service.addOperation(operation);
        refresh();
    }

    function refresh() {
        if (service) {
            var ops = service.loadOperations();
            if (ops && ops.length > 0) {
                load(ops);
                console.log("Загружено операций:", count);
            } else {
                console.error("Не удалось загрузить операции");
            }
        } else {
            console.error("Сервис операций не инициализирован");
        }
    }

    function loadByTypeOperation(type) {
            load(service.getTotalSumByCategory(type))
    }

    function loadByTypeCategory(categoryId, action) {
        loadOperation(service.getOperationByCategory(categoryId, action))
    }

    function loadOperation(operations) {
        clear();
        if (operations) {
            operations.forEach(function(op) {
                append({
                    id: op.id,
                    amount: op.amount,
                    action: op.action,
                    categoryId: op.categoryId,
                    date: op.date,
                    desc: op.desc
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
}
