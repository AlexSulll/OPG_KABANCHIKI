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
        if (operations && operations.length > 0) {
            for (var i = 0; i < operations.length; i++) {
                var op = operations[i];
                append({
                    id: op.id,
                    amount: op.amount,
                    action: op.action,
                    categoryId: op.categoryId,
                    date: op.date,
                    desc: op.desc
                });
            }
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

    function loadByType(type) {
            load(service.getOperationsByType(type))
    }

    function getSumByCategory(categoryId, categoryModel) {
        var result = {
            "icon": "",
            "name": "Неизвестная категория",
            "total": 0
        }

        // Находим категорию в модели категорий
        var category = categoryModel.getCategoryById(categoryId)
        if (category) {
            result.icon = category.pathToIcon
            result.name = category.nameCategory
        }

        // Считаем сумму операций
        for (var i = 0; i < count; i++) {
            var operation = get(i)
            if (operation.categoryId === categoryId) {
                result.total += operation.action === 0
                    ? -operation.amount
                    : operation.amount
            }
        }

        return result
    }
}
