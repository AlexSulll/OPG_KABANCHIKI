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


    function calculateChartData(operationModel, action) {  // поменять в mainpage на operationmodel
        //console.log("Calculating chart for action:", action);
        var data = [];
        var filtered = operationModel.loadByTypeOperationForCard(action);
        console.log("Filtered:", JSON.stringify(filtered));


        for (var i = 0; i < filtered.length; i++) {
            var cat = filtered[i]["categoryId"];
            var catTotal = filtered[i]["total"]; // счёт суммы не работает - надо получить через сервис
            if (catTotal > 0) {
                data.push({
                    value: catTotal,
                    color: getColorForCategory(cat.categoryId),
                    categoryId: cat,
                    name: filtered[i]["name"],
                    isExpense: action === 0
                })
            }
        }

        data.sort(function(a, b) { return b.value - a.value })
        if (data.length === 0) {
            data.push({
                value: 0,
                color: "",
                categoryId: "",
                name: "Нет данных",
                isExpense: action === 0  // Add this line
            })
        }
        sectors = data
        updateSectors()
        //console.log("CharFunc END:", JSON.stringify(sectors));
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
