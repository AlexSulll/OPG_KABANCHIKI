import QtQuick 2.0
import "../services" as Services
import "../models"

ListModel {
    id: operationModel
    objectName: "OperationModel"

    property real totalBalance: 0
    property var data: []
    property string currentPeriod: "All"
    property var dateFilterModel: null

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

    function loadByTypeOperation(type) {
            loadOperation(service.getTotalSumByCategory(type))
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
                    categoryName: op.categoryName,
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
        console.log("Data:", JSON.stringify(data));
        return data
    }

    function loadByTypeOperationForCardAndDateFiltering(type, period) {
        if (period==="All") {
            loadByTypeOperationForCard(type)
        }
        data = service.getFilteredCategories(type, period);
        console.log("Data:", JSON.stringify(data));
        return data
    }

    function formatDateForSQL(date) {
        if (!date) return ""
        return Qt.formatDate(date, "yyyy-MM-dd")
    }

    function getTotalSum() {
        var sum = 0
        if (!operationModel) return 0

        for (var i = 0; i < operationModel.count; i++) {
            var item = operationModel.get(i)
            if (item && ((!action && item.action === 0) || (action && item.action === 1))) {
                sum += item.total || 0
            }
        }
        return sum
    }

    function updateBalanceText() {
        if (balanceHidden) {
            header.headerText = "****** ₽"
        } else {
            header.headerText = Number(operationModel.totalBalance).toLocaleString(Qt.locale(), 'f', 2) + " ₽"
        }
    }

    function loadOperationsByCategoryAndPeriod(categoryId, action, period) {
        clear();
        if (service) {
            var dateRange = dateFilterModel.getDateRange(period);
            var operations = service.getOperationsByCategoryAndPeriod(categoryId, action, period, dateRange);
            if (operations) {
                operations.forEach(function(op) {
                    append({
                        id: op.id,
                        amount: op.amount,
                        action: op.action,
                        categoryId: op.categoryId,
                        categoryName: op.categoryName,
                        date: op.date,
                        desc: op.desc,
                        total: op.total || 0
                    });
                });
            } else {
                console.error("Не удалось загрузить операции по категории", categoryId, "и периоду", period);
            }
        } else {
            console.error("Сервис операций не инициализирован или dateFilterModel не передан");
        }
        console.log("LOADED OPERATIONS BY CATEGORY AND PERIOD:", categoryId, period, JSON.stringify(operations));
    }

    function getTotalSpentByCategory(categoryId) {
        var total = 0;
        if (service) {
            var operations = service.getOperationByCategory(categoryId, 0); // 0 - расходы
            for (var i = 0; i < operations.length; i++) {
                total += operations[i].amount;
            }
        }
        return total;
    }

    function getTimeSeriesData(period) {
        console.log("Getting time series data for period:", period);
        var result = [];
        var operations = service.loadExpOperations(); // Используем существующий метод

        if (!operations || operations.length === 0) {
            console.log("No operations found in database");
            return [
                { month: "JAN", year: "2024", value: 0, target: 10000 },
                { month: "FEB", year: "2024", value: 0, target: 10000 }
            ];
        }

        // Группируем операции по месяцам
        var monthlyData = {};
        var monthNames = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];

        operations.forEach(function(op) {
            if (!op.date) {
                console.log("Operation missing date:", op);
                return;
            }

            var dateParts = op.date.split(".");
            if (dateParts.length !== 3) {
                console.log("Invalid date format:", op.date);
                return;
            }

            var monthIndex = parseInt(dateParts[1]) - 1;
            if (isNaN(monthIndex) || monthIndex < 0 || monthIndex > 11) {
                console.log("Invalid month in date:", op.date);
                return;
            }

            var monthKey = monthNames[monthIndex] + "," + dateParts[2];

            if (!monthlyData[monthKey]) {
                monthlyData[monthKey] = {
                    month: monthNames[monthIndex],
                    year: dateParts[2],
                    value: 0,
                    target: 10000
                };
            }

            monthlyData[monthKey].value += op.amount;
        });

        // Преобразуем в массив
        for (var key in monthlyData) {
            result.push(monthlyData[key]);
        }

        // Сортируем по дате
        result.sort(function(a, b) {
            var aDate = new Date(a.year, monthNames.indexOf(a.month));
            var bDate = new Date(b.year, monthNames.indexOf(b.month));
            return aDate - bDate;
        });

        console.log("Generated time series data with", result.length, "months");
        return result.length > 0 ? result : [
            { month: "JAN", year: "2024", value: 0, target: 10000 },
            { month: "FEB", year: "2024", value: 0, target: 10000 }
        ];
    }

    function getAnalyticsDataForPopup(month) {
        return service.getExpensesByMonth(month)
    }
}
