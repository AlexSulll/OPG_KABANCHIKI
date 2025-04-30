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
    property int selectedSector: -1 // Индекс выбранного сектора

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
                        dateFilter.currentPeriod = selectedPeriod
                        selectedSector = -1

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
            anchors.verticalCenterOffset: Theme.paddingMedium

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

                property var sectorAngles: [] // Храним углы секторов для обработки кликов

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    var centerX = width / 2
                    var centerY = height / 2
                    var radius = Math.min(width, height) * 0.35
                    var lineWidth = radius * 0.55
                    var startAngle = -Math.PI/2
                    var total = 0
                    sectorAngles = [] // Очищаем массив углов

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

                        // Сохраняем углы сектора для обработки кликов
                        sectorAngles.push({
                            start: startAngle,
                            end: endAngle,
                            index: j,
                            radius: radius
                        })

                        // Если это выбранный сектор, рисуем его с большим радиусом
                        var currentRadius = (selectedSector === j) ? radius * 1.1 : radius
                        var currentLineWidth = (selectedSector === j) ? lineWidth * 1.1 : lineWidth

                        ctx.beginPath()
                        ctx.arc(centerX, centerY, currentRadius, startAngle, endAngle, false)
                        ctx.lineWidth = currentLineWidth
                        ctx.strokeStyle = sector.color || (isExpense ? "#FF6384" : "#36A2EB")
                        ctx.stroke()

                        startAngle = endAngle
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        var centerX = width / 2
                        var centerY = height / 2
                        var clickX = mouse.x - centerX
                        var clickY = mouse.y - centerY
                        var distance = Math.sqrt(clickX * clickX + clickY * clickY)
                        var clickAngle = Math.atan2(clickY, clickX)
                        var clickedInsideSector = false

                        // Нормализуем угол (-π до π) -> (0 до 2π)
                        if (clickAngle < 0) clickAngle += 2 * Math.PI

                        // Проверяем все сектора
                        for (var i = 0; i < sectorsCanvas.sectorAngles.length; i++) {
                            var sector = sectorsCanvas.sectorAngles[i]

                            // Учитываем увеличенный радиус для выбранного сектора
                            var sectorRadius = (selectedSector === sector.index) ? sector.radius * 1.1 : sector.radius
                            var sectorLineWidth = (selectedSector === sector.index) ? sector.radius * 0.55 * 1.1 : sector.radius * 0.55

                            // Диапазон радиусов для клика
                            var minRadius = Math.max(0, sectorRadius - sectorLineWidth/2)
                            var maxRadius = sectorRadius + sectorLineWidth/2

                            // Проверяем попадание в радиус
                            if (distance >= minRadius && distance <= maxRadius) {
                                // Нормализуем углы сектора
                                var startAngle = sector.start < 0 ? sector.start + 2*Math.PI : sector.start
                                var endAngle = sector.end < 0 ? sector.end + 2*Math.PI : sector.end

                                // Проверяем попадание в угол
                                var angleInSector = false

                                if (startAngle <= endAngle) {
                                    angleInSector = (clickAngle >= startAngle && clickAngle <= endAngle)
                                } else {
                                    // Сектор пересекает 0
                                    angleInSector = (clickAngle >= startAngle || clickAngle <= endAngle)
                                }

                                if (angleInSector) {
                                    clickedInsideSector = true
                                    // Нашли сектор, на который кликнули
                                    if (selectedSector === sector.index) {
                                        selectedSector = -1 // Снимаем выделение
                                    } else {
                                        selectedSector = sector.index // Выделяем новый сектор
                                    }
                                    sectorsCanvas.requestPaint()
                                    break // Прерываем цикл, так как нашли нужный сектор
                                }
                            }
                        }

                        // Клик вне секторов - снимаем выделение
                        if (!clickedInsideSector && selectedSector !== -1) {
                            selectedSector = -1
                            sectorsCanvas.requestPaint()
                        }
                    }
                }
            }

            Column {
                id: infoColumn
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
                        if (selectedSector >= 0 && selectedSector < sectors.length) {
                            // Показываем значение выбранного сектора
                            return Number(sectors[selectedSector].value).toLocaleString(Qt.locale(), 'f', 2) + " ₽"
                        } else {
                            // Показываем общую сумму
                            var sum = 0
                            for (var i = 0; i < sectors.length; i++) {
                                if ((isExpense && sectors[i].isExpense) || (!isExpense && !sectors[i].isExpense)) {
                                    sum += sectors[i].value
                                }
                            }
                            return Number(sum).toLocaleString(Qt.locale(), 'f', 2) + " ₽"
                        }
                    }
                    color: isExpense ? "#FF6384" : Theme.highlightColor
                    font.pixelSize: Theme.fontSizeLarge
                    font.bold: true
                }

                Label {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    text: {
                        if (selectedSector >= 0 && selectedSector < sectors.length) {
                            // Показываем название выбранной категории
                            return sectors[selectedSector].name || "Категория"
                        } else {
                            // Показываем количество категорий
                            var count = 0
                            for (var i = 0; i < sectors.length; i++) {
                                if ((isExpense && sectors[i].isExpense) || (!isExpense && !sectors[i].isExpense)) {
                                    count++
                                }
                            }
                            return count===1 && sectors[0]["value"]===0 ? "Нет категорий" : count + " категори"+ (count === 1 ? "я" : (count >= 5 ? "й" : "и") )
                        }
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
        selectedSector = -1 // Сброс выбранного сектора при изменении данных
        backgroundRing.requestPaint()
        sectorsCanvas.requestPaint()
    }
}
