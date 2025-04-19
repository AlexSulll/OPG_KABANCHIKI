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
        clear();
        operations.forEach(function(op) {
             append({
                    id: op.id,
                    amount: op.amount,
                    action: op.action,
                    category: op.categoryId,
                    date: op.date,
                    desc: op.desc
            });
        });
    }

    function add(operation) {
        console.log("Данные операции:", operation);
        service.addOperation(operation);
        refresh();
    }

    function refresh() {
        if (service) {
            var ops = service.loadOperations();
            load(ops);
            console.log("Модель обновлена, записей:", count);
        }
    }

    function loadByType(type) {
            load(service.getOperationsByType(type))
    }
}
