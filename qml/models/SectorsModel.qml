import QtQuick 2.0
import Sailfish.Silica 1.0
import "../services" as Services

ListModel {
    id: sectorModel
    objectName: "SectorModel"


    property var sectors:  []
    property real total: 0

    function getTotalByCategory(categoryId) {
        var total = 0
        for (var i = 0; i < count; i++) {
            var item = get(i)
            if (item.categoryId === categoryId) {
                total += item.total
            }
        }
        console.log("Total for category", categoryId, ":", total)
        return total
    }


    function getColorForCategory(categoryId) {
        var colors = [
            "#FF6384", "#36A2EB", "#FFCE56", "#4BC0C0",
            "#9966FF", "#FF9F40", "#8AC24A", "#FF5722"
        ]
        return colors[categoryId % colors.length]
    }


    function calculateChartData(operationModel, action) {
        var data = [];
        var filtered = operationModel.loadByTypeOperationForCard(action);
        console.log("Filtered data:", JSON.stringify(filtered));

        // Рассчитываем общую сумму для текущего типа операций
        var totalForType = 0;
        for (var i = 0; i < filtered.length; i++) {
            totalForType += filtered[i].total;
        }

        // Формируем данные для секторов
        for (var j = 0; j < filtered.length; j++) {
            var item = filtered[j];
            if (item.total > 0) {
                data.push({
                    value: item.total,
                    percentage: totalForType > 0 ? (item.total / totalForType * 100) : 0,
                    color: getColorForCategory(item.categoryId),
                    categoryId: item.categoryId,
                    name: item.name,
                    isExpense: action === 0
                });
            }
        }

        data.sort(function(a, b) { return b.value - a.value; });

        if (data.length === 0) {
            data.push({
                value: 0,
                percentage: 0,
                color: "",
                categoryId: "",
                name: "Нет данных",
                isExpense: action === 0
            });
        }

        sectors = data;
        updateSectors();
    }

    function updateSectors() {
        clear();
        for (var i = 0; i < sectors.length; i++) {
            append({
                value: sectors[i].value,
                color: sectors[i].color,
                categoryId: sectors[i].categoryId,
                name: sectors[i].name,
                isExpense: sectors[i].isExpense
            });
        }
    }
}
