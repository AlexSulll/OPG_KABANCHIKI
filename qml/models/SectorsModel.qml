import QtQuick 2.0
import Sailfish.Silica 1.0
import "../services" as Services

ListModel {
    id: sectorModel
    objectName: "SectorModel"

    property var sectors: calculateChartData(categoryModel, 0) || []
    property real total: operationModel.totalBalance

    function getTotalByCategory(categoryId) {
        var total = 0
        for (var i = 0; i < count; i++) {
            var item = get(i)
            if (item.categoryId === categoryId) {
                total += item.total
            }
        }
        return total
    }

    function getColorForCategory(categoryId) {
        var colors = [
            "#FF6384", "#36A2EB", "#FFCE56", "#4BC0C0",
            "#9966FF", "#FF9F40", "#8AC24A", "#FF5722"
        ]
        return colors[categoryId % colors.length]
    }

    function calculateChartData(categoryModel, action) {
            var data = []
            var filtered = categoryModel.filteredCategories(action)

            for (var i = 0; i < filtered.length; i++) {
                var cat = filtered[i]
                var catTotal = getTotalByCategory(cat.categoryId)
                if (catTotal > 0) {
                    data.push({
                        value: catTotal,
                        color: getColorForCategory(cat.categoryId),
                        categoryId: cat.categoryId,
                        name: cat.nameCategory
                    })
                }
            }

            data.sort(function(a, b) { return b.value - a.value })
            if (data.length === 0) {
                data.push({
                    value: 0,
                    color: "",
                    name: "Нет данных"
                })
            }
            sectors = data
            updateSectors()
        }

    function updateSectors() {
        clear();
        for (var i = 0; i < sectors.length; i++) {
            append({
                categoryId: sectors[i].value,
                nameCategory: sectors[i].color,
                pathToIcon: sectors[i].name,
            });
        }
    }
}
