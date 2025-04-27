import QtQuick 2.0
import Sailfish.Silica 1.0
import "../models" as Models


Item {
    id: cardRoot
    width: parent.width - 2 * Theme.paddingLarge
    height: width

    property real rotationAngle: 0
    property real scaleFactor: 1.0
    property var sectors: []
    property var period: []
    property real totalValue: 0
    property bool isExpense: true  // true - расходы, false - доходы
    property string selectedPeriod: "All"
    property var dateRange: []
    property var operationModel: null
    property string currentPeriod: "All"

    Models.DateFilterModel {
        id: dateModel
        operationModel: operationModel
    }

    Rectangle {
        id: cardBackground
        anchors.fill: parent
        radius: Theme.paddingLarge * 1.5
        color: Theme.rgba("#24224f", 0.9)

        Row {
            id: periodSelector
            anchors {
                top: parent.top
                topMargin: Theme.paddingMedium
                horizontalCenter: parent.horizontalCenter
            }
            spacing: Theme.paddingLarge

            Repeater {
                model: dateModel
                delegate: BackgroundItem {
                    width: periodLabel.width + Theme.paddingMedium * 2
                    height: periodLabel.height + Theme.paddingSmall * 2

                    Label {
                        id: periodLabel
                        anchors.centerIn: parent
                        text: dateLabel
                        color: selectedPeriod === dateId ? Theme.highlightColor : Theme.secondaryColor
                        font.pixelSize: Theme.fontSizeExtraLarge
                        font.underline: selectedPeriod === dateId
                    }

                    onClicked: {
                            selectedPeriod = dateId;
                            operationModel.currentPeriod = selectedPeriod


                            var filteredOps = operationModel.service.getFilteredCategories(mainpage.action, selectedPeriod)
                            // Обновляем модель
                            operationModel.loadOperation(filteredOps)
                            operationModel.calculateTotalBalance()

                            // Обновляем график
                            isExpense = mainpage.action === 0
                            sectorModel.calculateChartData(operationModel, mainpage.action)
                            sectorsCanvas.requestPaint();
                            backgroundRing.requestPaint();
                    }
                }
            }
        }


        Item {
            id: chartContainer
            width: parent.width * 0.8
            height: width
            anchors.centerIn: parent
            anchors.verticalCenterOffset: Theme.paddingMedium  // Make space for period selector

            Canvas {
                id: backgroundRing
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    var centerX = width / 2
                    var centerY = height / 2
                    var radius = Math.min(width, height) * 0.35
                    var lineWidth = radius * 0.75

                    ctx.beginPath()
                    ctx.arc(centerX, centerY, radius, 0, Math.PI * 2, false)
                    ctx.lineWidth = lineWidth
                    ctx.strokeStyle = isExpense ? Theme.rgba("#FF6384", 0.2) : Theme.rgba("#36A2EB", 0.2)
                    ctx.stroke()
                }
            }

            Canvas {
                id: sectorsCanvas
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    var centerX = width / 2
                    var centerY = height / 2
                    var radius = Math.min(width, height) * 0.35
                    var lineWidth = radius * 0.55
                    var startAngle = -Math.PI/2
                    var total = 0

                    // Считаем общую сумму для текущего типа операций
                    for (var i = 0; i < sectors.length; i++) {
                        if ((isExpense && sectors[i].isExpense) || (!isExpense && !sectors[i].isExpense)) {
                            total += sectors[i].value
                        }
                    }

                    if (total <= 0) {
                        // Если нет данных, рисуем серое кольцо
                        ctx.beginPath()
                        ctx.arc(centerX, centerY, radius, 0, Math.PI * 2, false)
                        ctx.lineWidth = lineWidth
                        ctx.strokeStyle = Theme.rgba(Theme.secondaryColor, 0.2)
                        ctx.stroke()
                        return
                    }

                    // Рисуем сектора для текущего типа операций
                    for (var j = 0; j < sectors.length; j++) {
                        var sector = sectors[j]
                        // Пропускаем сектора другого типа
                        if ((isExpense && !sector.isExpense) || (!isExpense && sector.isExpense)) {
                            continue
                        }

                        var angle = (sector.value / total) * Math.PI * 2
                        var endAngle = startAngle + angle

                        ctx.beginPath()
                        ctx.arc(centerX, centerY, radius, startAngle, endAngle, false)
                        ctx.lineWidth = lineWidth
                        ctx.strokeStyle = sector.color || (isExpense ? "#FF6384" : "#36A2EB")
                        ctx.stroke()

                        startAngle = endAngle
                    }
                }
            }

            Column {
                anchors.centerIn: parent
                width: parent.width * 0.6
                spacing: Theme.paddingSmall

                Label {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    text: isExpense ? "Расходы" : "Доходы"
                    color: Theme.primaryColor
                    font.pixelSize: Theme.fontSizeSmall
                }

                Label {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    text: {
                        var sum = 0
                        for (var i = 0; i < sectors.length; i++) {
                            if ((isExpense && sectors[i].isExpense) || (!isExpense && !sectors[i].isExpense)) {
                                sum += sectors[i].value
                            }
                        }
                        return Number(sum).toLocaleString(Qt.locale(), 'f', 2) + " ₽"
                    }
                    color: isExpense ? "#FF6384" : Theme.highlightColor
                    font.pixelSize: Theme.fontSizeLarge
                    font.bold: true
                }

                Label {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    text:  {
                        var count = 0
                        for (var i = 0; i < sectors.length; i++) {
                            if ((isExpense && sectors[i].isExpense) || (!isExpense && !sectors[i].isExpense)) {
                                count++
                            }
                        }
                        return count===1 && sectors[0]["value"]===0 ? "Нет категорий" : count + " категории"
                    }
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                }
            }
        }
    }

    ParallelAnimation {
        id: appearAnimation
        running: true
        NumberAnimation {
            target: cardRoot
            property: "rotationAngle"
            from: -15
            to: 0
            duration: 800
            easing.type: Easing.OutBack
        }
        NumberAnimation {
            target: cardRoot
            property: "scaleFactor"
            from: 0.8
            to: 1.0
            duration: 600
            easing.type: Easing.OutQuad
        }
    }

    onSectorsChanged: {
        console.log("Sectors changed:", JSON.stringify(sectors));
        backgroundRing.requestPaint()
        sectorsCanvas.requestPaint()
    }
}
