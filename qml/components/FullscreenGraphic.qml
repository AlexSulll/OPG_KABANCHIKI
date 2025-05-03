import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: fullscreenGraphPage
    allowedOrientations: Orientation.Landscape
    backgroundColor: "white"
    property var timeSeriesData
    property var selectedMonthData

    property real scaleFactor: 0.9
    Behavior on scaleFactor { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }

    Component.onCompleted: scaleFactor = 1.0

    SilicaFlickable {
        anchors.fill: parent
        contentWidth: chartContainer.width
        contentHeight: parent.height
        interactive: contentWidth > width
        clip: true

        Item {
            id: chartContainer
            width: Math.max(parent.width, timeSeriesData ? (timeSeriesData.length * 120 + 160) : parent.width) // Увеличил отступы
            height: parent.height
            scale: fullscreenGraphPage.scaleFactor
            transformOrigin: Item.Center
            anchors.left: parent.left
            anchors.leftMargin: Theme.paddingLarge * 2 // Уменьшил отступ слева

            Canvas {
                id: fullscreenChartCanvas
                anchors.fill: parent

                property var clickAreas: ({})
                property color lineColor: "#24224f"
                property color pointColor: "#24224f"
                property color glowColor: Theme.secondaryColor
                property color textColor: "#24224f"
                property real lineWidth: 7
                property real pointRadius: 10
                property real glowRadius: 16

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();
                    ctx.clearRect(0, 0, width, height);

                    if (!timeSeriesData || timeSeriesData.length < 2) return;

                    // Рассчитываем масштаб
                    var maxValue = Math.max.apply(null, timeSeriesData.map(function(d) {
                        return d.value;
                    }));

                    // Добавляем 10% сверху для лучшего отображения
                    maxValue *= 1.1;

                    var leftMargin = 80; // Увеличил отступ слева для подписей
                    var rightMargin = 80; // Увеличил отступ справа
                    var availableWidth = width - leftMargin - rightMargin;
                    var xStep = availableWidth / (timeSeriesData.length - 1);
                    var chartHeight = height * 0.7;
                    var bottomMargin = 70; // Увеличил отступ снизу для подписей

                    // Рисуем сетку и оси
                    ctx.strokeStyle = "#e0e0e0";
                    ctx.lineWidth = 2;

                    // Горизонтальные линии
                    var gridLines = 5;
                    for (var g = 0; g <= gridLines; g++) {
                        var gy = height - bottomMargin - (g/gridLines * chartHeight);
                        ctx.beginPath();
                        ctx.moveTo(leftMargin, gy);
                        ctx.lineTo(width - rightMargin, gy);
                        ctx.stroke();

                        // Подписи значений
                        ctx.fillStyle = textColor;
                        ctx.font = Theme.fontSizeExtraSmall * 0.75 + "px sans-serif";
                        ctx.textAlign = "right";
                        ctx.fillText((maxValue * (g/gridLines)/1000).toFixed(1) + "k", leftMargin - 10, gy + 4);
                    }

                    // Ось X
                    ctx.beginPath();
                    ctx.moveTo(leftMargin, height - bottomMargin);
                    ctx.lineTo(width - rightMargin, height - bottomMargin);
                    ctx.stroke();

                    // Рисуем линию графика
                    ctx.strokeStyle = lineColor;
                    ctx.lineWidth = lineWidth;
                    ctx.lineJoin = "round";
                    ctx.lineCap = "round";
                    ctx.beginPath();

                    for (var i = 0; i < timeSeriesData.length; i++) {
                        var x = leftMargin + i * xStep;
                        var y = height - bottomMargin - (timeSeriesData[i].value / maxValue * chartHeight);

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
                        x = leftMargin + j * xStep;
                        y = height - bottomMargin - (timeSeriesData[j].value / maxValue * chartHeight);

                        // Эффект свечения
                        ctx.shadowColor = glowColor;
                        ctx.shadowBlur = 10;
                        ctx.beginPath();
                        ctx.arc(x, y, glowRadius, 0, Math.PI * 2);
                        ctx.fillStyle = glowColor;
                        ctx.fill();
                        ctx.shadowColor = "transparent";

                        // Точка
                        ctx.beginPath();
                        ctx.arc(x, y, pointRadius, 0, Math.PI * 2);
                        ctx.fillStyle = pointColor;
                        ctx.fill();

                        // Подпись месяца
                        ctx.fillStyle = textColor;
                        ctx.font = "bold " + Theme.fontSizeExtraSmall * 0.7 + "px sans-serif";
                        ctx.textAlign = "center";

                        var monthText = timeSeriesData[j].month + (timeSeriesData[j].year ? "," + timeSeriesData[j].year : "");
                        ctx.fillText(monthText, x, height - (bottomMargin / 2));

                        // Подпись значения
                        var valueY = y - 25;
                        if (valueY < 30) valueY = y + 30;

                        ctx.fillStyle = pointColor;
                        ctx.font = "bold " + Theme.fontSizeExtraSmall + "px sans-serif";
                        ctx.textAlign = "center";

                        var valueText = (timeSeriesData[j].value/1000).toFixed(1) + "k";
                        ctx.fillText(valueText, x, valueY);

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
                        for (var i in fullscreenChartCanvas.clickAreas) {
                            var area = fullscreenChartCanvas.clickAreas[i];
                            var dx = mouse.x - area.x;
                            var dy = mouse.y - area.y;
                            if (Math.sqrt(dx*dx + dy*dy) <= area.radius) {
                                selectedMonthData = area.data;
                                break;
                            }
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: Theme.rgba("#24224f", 0.4)
        border.width: 0.5
        radius: Theme.paddingMedium
        z: -1
    }

    IconButton {
        icon.source: "image://theme/icon-m-close"
        anchors {
            top: parent.top
            right: parent.right
            margins: Theme.paddingLarge
        }
        onClicked: {
            fullscreenGraphPage.scaleFactor = 0.9;
            pageStack.pop();
        }
    }

    Label {
        anchors.centerIn: parent
        visible: !timeSeriesData || timeSeriesData.length === 0
        text: timeSeriesData ? qsTr("No data available") : qsTr("Loading...")
        color: "#24224f"
        font.pixelSize: Theme.fontSizeLarge
    }
}
