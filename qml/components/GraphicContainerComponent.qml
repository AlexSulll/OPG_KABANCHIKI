import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: graphic
    width: parent.width
    height: 600
    clip: true
    anchors.top: fullStaticCard.bottom

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
            width: Math.max(chartFlickable.width, timeSeriesData.length * 120 + 40) // Увеличил базовую ширину
            height: parent.height

            Canvas {
                id: chartCanvas
                anchors.fill: parent

                property var clickAreas: ({})

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();

                    if (timeSeriesData.length < 2) return;

                    // Рассчитываем масштаб
                    var maxValue = Math.max.apply(null, timeSeriesData.map(function(d) {
                        return Math.max(d.value, d.target);
                    }));
                    var availableWidth = width - 80; // Оставляем отступы по бокам
                    var xStep = availableWidth / (timeSeriesData.length - 1);


                    // Рисуем линию графика
                    ctx.strokeStyle = "#24224f";
                    ctx.lineWidth = 7;
                    ctx.lineJoin = "round";
                    ctx.beginPath();

                    for (var i = 0; i < timeSeriesData.length; i++) {
                        var x = 40 + i * xStep; // Начальный отступ 40px
                        var y = height - 50 - (timeSeriesData[i].value / maxValue * (height * 0.6));

                        if (i === 0) {
                            ctx.moveTo(x, y);
                        } else {
                            ctx.lineTo(x, y);
                        }
                    }
                    ctx.stroke();

                    // Очищаем области кликов
                    clickAreas = {};

                    // Рисуем точки и подписи
                    for (var j = 0; j < timeSeriesData.length; j++) {
                        x = 40 + j * xStep;
                        y = height - 50 - (timeSeriesData[j].value / maxValue * (height * 0.6));

                        // Эффект свечения с анимацией пульсации
                        ctx.shadowColor = Theme.secondaryColor;
                        ctx.shadowBlur = 10 * pulseSize;
                        ctx.beginPath();
                        ctx.arc(x, y, 16 * pulseSize, 0, Math.PI * 2);
                        ctx.fillStyle = Theme.secondaryColor;
                        ctx.fill();

                        // Точка с анимацией пульсации
                        ctx.beginPath();
                        ctx.arc(x, y, 10 * pulseSize, 0, Math.PI * 2);
                        ctx.fillStyle = "#24224f";
                        ctx.fill();

                        // Подпись месяца
                        ctx.fillStyle = "#24224f";
                        ctx.font = "bold " + Theme.fontSizeSmall*0.6 + "px sans-serif";
                        ctx.textAlign = "center";
                        ctx.fillText(timeSeriesData[j].month+","+timeSeriesData[j].year, x, height - 20);

                        // Подпись значения
                        var valueY = y - 20;
                        if (valueY < 30) valueY = y + 30;

                        ctx.fillStyle = "#24224f";
                        ctx.font = "bold " + Theme.fontSizeExtraSmall + "px sans-serif";
                        ctx.textAlign = "center";
                        ctx.fillText((timeSeriesData[j].value/1000).toFixed(1) + "k", x, valueY);

                        // Сохраняем область клика
                        clickAreas[j] = {
                            x: x,
                            y: y,
                            radius: 50,
                            data: timeSeriesData[j]
                        };
                    }
                }

                MouseArea {
                    anchors.fill: parent
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
