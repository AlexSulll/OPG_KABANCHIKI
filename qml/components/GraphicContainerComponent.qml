import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: graphic
    width: parent.width
    height: 600
    clip: true
    anchors.top: fullStaticCard.bottom
    onVisibleChanged: {
        if (visible && chartCanvas) {
            chartCanvas.requestPaint();
        }
    }
    property real pulseSize: 1.0
    property real pulseOpacity: 0.3
    SequentialAnimation {
        running: true
        loops: Animation.Infinite
        ParallelAnimation {
            NumberAnimation {
                target: graphic
                property: "pulseSize"
                from: 1.0
                to: 1.4 // Увеличиваем масштаб пульсации
                duration: 1000 // Увеличиваем длительность для плавности
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                target: graphic
                property: "pulseOpacity"
                from: 0.3
                to: 0.7 // Увеличиваем изменение прозрачности
                duration: 1000
                easing.type: Easing.InOutQuad
            }
        }
        ParallelAnimation {
            NumberAnimation {
                target: graphic
                property: "pulseSize"
                from: 1.4
                to: 1.0
                duration: 1000
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                target: graphic
                property: "pulseOpacity"
                from: 0.7
                to: 0.3
                duration: 1000
                easing.type: Easing.InOutQuad
            }
        }
    }

    Component.onCompleted: {
        chartCanvas.requestPaint();
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: Theme.rgba("#24224f", 0.4)
        border.width: 0.5
        radius: Theme.paddingMedium
    }

    IconButton {
        id: graphSettingsButton
        icon.source: "image://theme/icon-l-gesture"
        icon.color: "#24224f"
        z: 50
        anchors {
            top: parent.top
            left: parent.left
            margins: Theme.paddingMedium
        }
        onClicked: {
            pageStack.push(Qt.resolvedUrl("FullscreenGraphic.qml"), {
                "timeSeriesData": timeSeriesData,
                "selectedMonthData": selectedMonthData
            });
        }
    }

    SilicaFlickable {
        id: chartFlickable
        anchors {
            fill: parent
            margins: Theme.paddingMedium
        }
        contentWidth: chartContainer.width
        interactive: contentWidth > width

        Item {
            id: chartContainer
            width: Math.max(chartFlickable.width, timeSeriesData.length * 200 + 40)
            height: parent.height


            Canvas {
                id: chartCanvas
                anchors.fill: parent

                property var clickAreas: ({})
                property var highlightedPoint: -1

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();

                    if (timeSeriesData.length < 2) return;

                    // Рассчитываем масштаб
                    var maxValue = Math.max.apply(null, timeSeriesData.map(function(d) {
                        return Math.max(d.value, d.target);
                    }));
                    var availableWidth = width - 80;
                    var xStep = availableWidth / (timeSeriesData.length - 1);
                    var chartBottom = height - 50;
                    var chartTop = 50;

                    // Современная заливка под графиком с многослойным градиентом
                    ctx.beginPath();
                    ctx.moveTo(40, chartBottom);

                    // Создаем массив точек для плавного графика
                    var points = [];
                    for (var i = 0; i < timeSeriesData.length; i++) {
                        var x = 40 + i * xStep;
                        var y = chartBottom - (timeSeriesData[i].value / maxValue * (height * 0.6));
                        points.push({x: x, y: y});
                        ctx.lineTo(x, y);
                    }

                    ctx.lineTo(40 + (timeSeriesData.length - 1) * xStep, chartBottom);
                    ctx.closePath();

                    // Основной градиент с прозрачностью
                    var gradient = ctx.createLinearGradient(0, chartTop, 0, chartBottom);
                    gradient.addColorStop(0, Theme.rgba("#3a3a8f", 0.25));
                    gradient.addColorStop(0.5, Theme.rgba("#3a3a8f", 0.15));
                    gradient.addColorStop(1, Theme.rgba("#3a3a8f", 0.05));

                    // Второй градиент для эффекта свечения
                    var glowGradient = ctx.createLinearGradient(0, chartTop, 0, chartBottom);
                    glowGradient.addColorStop(0, Theme.rgba("#6a6acf", 0.1));
                    glowGradient.addColorStop(1, "transparent");

                    // Рисуем основную заливку
                    ctx.fillStyle = gradient;
                    ctx.fill();

                    // Добавляем эффект свечения сверху
                    ctx.beginPath();
                    ctx.moveTo(40, chartBottom);
                    for (var j = 0; j < points.length; j++) {
                        ctx.lineTo(points[j].x, points[j].y);
                    }
                    ctx.lineTo(40 + (timeSeriesData.length - 1) * xStep, chartBottom);
                    ctx.closePath();

                    ctx.fillStyle = glowGradient;
                    ctx.fill();

                    // Добавляем тонкую белую подсветку вверху графика
                    ctx.beginPath();
                    ctx.moveTo(points[0].x, points[0].y);
                    for (var k = 1; k < points.length; k++) {
                        ctx.lineTo(points[k].x, points[k].y);
                    }
                    ctx.strokeStyle = Theme.rgba("white", 0.15);
                    ctx.lineWidth = 2;
                    ctx.stroke();

                    // Рисуем линию графика с градиентом
                    ctx.beginPath();
                    ctx.moveTo(points[0].x, points[0].y);

                    var lineGradient = ctx.createLinearGradient(0, chartTop, 0, chartBottom);
                    lineGradient.addColorStop(0, "#6a6acf");
                    lineGradient.addColorStop(1, "#24224f");

                    for (var l = 1; l < points.length; l++) {
                        ctx.lineTo(points[l].x, points[l].y);
                    }

                    ctx.strokeStyle = lineGradient;
                    ctx.lineWidth = 4;
                    ctx.lineJoin = "round";
                    ctx.shadowColor = Theme.rgba("#6a6acf", 0.4);
                    ctx.shadowBlur = 10;
                    ctx.stroke();
                    ctx.shadowBlur = 0;

                    // Очищаем области кликов
                    clickAreas = {};

                    // Рисуем точки и подписи
                    for (var k = 0; k < timeSeriesData.length; k++) {
                        x = 40 + k * xStep;
                        y = chartBottom - (timeSeriesData[k].value / maxValue * (height * 0.6));

                        // Эффект пульсации (внешнее свечение) - усиленный
                        if (k === highlightedPoint || highlightedPoint === -1) {
                            ctx.shadowColor = Theme.rgba("#24224f", pulseOpacity);
                            ctx.shadowBlur = 15 * pulseSize; // Увеличиваем размытие
                            ctx.beginPath();
                            ctx.arc(x, y, 20 * pulseSize, 0, Math.PI * 2); // Увеличиваем радиус
                            ctx.fillStyle = Theme.rgba("#24224f", pulseOpacity * 0.7);
                            ctx.fill();
                            ctx.shadowBlur = 0;

                            // Добавляем второй слой пульсации для большего эффекта
                            ctx.shadowColor = Theme.rgba("#24224f", pulseOpacity * 0.5);
                            ctx.shadowBlur = 25 * (pulseSize * 0.7);
                            ctx.beginPath();
                            ctx.arc(x, y, 30 * (pulseSize * 0.7), 0, Math.PI * 2);
                            ctx.fillStyle = "transparent";
                            ctx.fill();
                            ctx.shadowBlur = 0;
                        }

                        // Белый кружок с тенью для точки - увеличенный
                        ctx.shadowColor = Theme.rgba("#24224f", 0.3);
                        ctx.shadowBlur = 8; // Увеличиваем тень
                        ctx.beginPath();
                        ctx.arc(x, y, 12 * (k === highlightedPoint ? pulseSize * 1.2 : 1), 0, Math.PI * 2);
                        ctx.fillStyle = "white";
                        ctx.fill();
                        ctx.shadowBlur = 0;

                        // Цветной кружок точки с пульсацией - более выраженный
                        var pointSize = 10 * (k === highlightedPoint ? pulseSize * 1.1 : 1);
                        ctx.beginPath();
                        ctx.arc(x, y, pointSize, 0, Math.PI * 2);
                        ctx.fillStyle = "#24224f";
                        ctx.fill();

                        // Подпись месяца
                        ctx.fillStyle = Theme.rgba("#24224f", 0.8);
                        ctx.font = "bold " + Theme.fontSizeSmall*0.6 + "px sans-serif";
                        ctx.textAlign = "center";
                        ctx.fillText(timeSeriesData[k].month+","+timeSeriesData[k].year, x, height - 20);

                        // Подпись значения в кружке с пульсацией - усиленная
                        var valueText = (timeSeriesData[k].value/1000).toFixed(1) + "k";
                        var textWidth = ctx.measureText(valueText).width;
                        var circleRadius = Math.max(textWidth, 20) + 15;

                        // Фон для значения с эффектом пульсации - более выраженный
                        if (k === highlightedPoint || highlightedPoint === -1) {
                            ctx.beginPath();
                            ctx.arc(x, y - 30, (circleRadius/2) * (k === highlightedPoint ? pulseSize * 1.1 : 1), 0, Math.PI * 2);
                            ctx.fillStyle = "white";
                            ctx.fill();
                            ctx.strokeStyle = "#24224f";
                            ctx.lineWidth = 1.5; // Более толстая граница
                            ctx.stroke();

                            // Добавляем тень для плавающего эффекта
                            ctx.shadowColor = Theme.rgba("#24224f", 0.2);
                            ctx.shadowBlur = 5 * (k === highlightedPoint ? pulseSize : 1);
                            ctx.fill();
                            ctx.shadowBlur = 0;
                        }

                        // Текст значения - более крупный и контрастный
                        ctx.fillStyle = "#24224f";
                        ctx.font = "bold " + Theme.fontSizeExtraSmall * 0.8 + "px sans-serif";
                        ctx.textAlign = "center";
                        ctx.fillText(valueText, x, y - 28);

                        // Сохраняем область клика
                        clickAreas[k] = {
                            x: x,
                            y: y,
                            radius: 50, // Увеличиваем область клика
                            data: timeSeriesData[k]
                        };
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onContainsMouseChanged: {
                        if (!containsMouse) {
                            chartCanvas.highlightedPoint = -1;
                            chartCanvas.requestPaint();
                        }
                    }
                    onPositionChanged: {
                        for (var i in chartCanvas.clickAreas) {
                            var area = chartCanvas.clickAreas[i];
                            var dx = mouse.x - area.x;
                            var dy = mouse.y - area.y;
                            if (Math.sqrt(dx*dx + dy*dy) <= area.radius) {
                                if (chartCanvas.highlightedPoint != i) {
                                    chartCanvas.highlightedPoint = i;
                                    chartCanvas.requestPaint();
                                }
                                return;
                            }
                        }
                        if (chartCanvas.highlightedPoint != -1) {
                            chartCanvas.highlightedPoint = -1;
                            chartCanvas.requestPaint();
                        }
                    }
                    onClicked: {
                        for (var i in chartCanvas.clickAreas) {
                            var area = chartCanvas.clickAreas[i];
                            var dx = mouse.x - area.x;
                            var dy = mouse.y - area.y;
                            if (Math.sqrt(dx*dx + dy*dy) <= area.radius) {
                                selectedMonthData = area.data;
                                showMonthPopup = true;
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
}
