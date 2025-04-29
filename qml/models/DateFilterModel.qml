import QtQuick 2.0

ListModel {
    id: root

    property var operationModel: null
    property string currentPeriod: "All"
    signal filterChanged(var filteredOperations)
    property var filteredOperations: []

    ListElement { dateId: "week"; dateLabel: "Неделя" }
    ListElement { dateId: "month"; dateLabel: "Месяц" }
    ListElement { dateId: "year"; dateLabel: "Год" }
    ListElement { dateId: "All"; dateLabel: "Все" }

    function filterOperationsByPeriod(operations, period) {
        if (!operations) {
            console.warn("No operations provided");
            return [];
        }

        currentPeriod = period || currentPeriod;
        if (currentPeriod === "All") {
            filteredOperations = operations.slice(); // Создаем копию массива
            filterChanged(filteredOperations);
            return filteredOperations;
        }
        var dateRange = getDateRange(currentPeriod);
        filteredOperations = [];

        for (var i = 0; i < operations.length; i++) {
            var op = operations[i];
            var opDate = parseDate(op.date);

            if (opDate && opDate >= dateRange.fromDate && opDate <= dateRange.toDate) {
                filteredOperations.push(op);
            }
        }

        filterChanged(filteredOperations);
        return filteredOperations;
    }

    function getDateRange(period) {
        var now = new Date()
        var fromDate = new Date(now)
        var toDate = new Date(now)

        switch(period) {
            case "week":
                var day = fromDate.getDay()
                var diff = fromDate.getDate() - day + (day === 0 ? -6 : 1)
                fromDate.setDate(diff)
                fromDate.setHours(0,0,0,0)
                toDate = new Date(fromDate)
                toDate.setDate(fromDate.getDate() + 6)
                toDate.setHours(23,59,59,999)
                break
            case "month":
                fromDate.setDate(1)
                fromDate.setHours(0,0,0,0)
                toDate = new Date(fromDate.getFullYear(), fromDate.getMonth() + 1, 0)
                toDate.setHours(23,59,59,999)
                break
            case "year":
                fromDate.setMonth(0, 1)
                fromDate.setHours(0,0,0,0)
                toDate = new Date(fromDate.getFullYear(), 11, 31)
                toDate.setHours(23,59,59,999)
                break
            case "All":
                return {
                    fromDate: new Date(0), // Минимальная дата
                    toDate: new Date(8640000000000000), // Максимальная дата
                    fromDateFormatted: "Все",
                    toDateFormatted: "операции"
                }
            default:
                console.error("Unknown period:", period)
                return {
                    fromDate: new Date(0),
                    toDate: new Date(8640000000000000),
                    fromDateFormatted: "Все",
                    toDateFormatted: "операции"
                }
        }

        return {
            fromDate: formatDateForSQL(fromDate),
            toDate: formatDateForSQL(toDate),
            fromDateFormatted: formatDateForSQL(fromDate),
            toDateFormatted: formatDateForSQL(toDate)
        }
    }

    function formatDateForSQL(date) {
        if (!date) return ""
        return Qt.formatDate(date, "yyyy-MM-dd")
    }
}
