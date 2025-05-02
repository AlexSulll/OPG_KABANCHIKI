import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

BasePage {
    id: analyticsPage
    allowedOrientations: Orientation.All

    // Цвета для графика
    readonly property color expenseColor: "#FF6B6B"
    readonly property color incomeColor: "#4ECDC4"
    property bool isExpense: true
    property color currentColor: isExpense ? expenseColor : incomeColor

    // Тестовые данные за 6 месяцев
    property var timeSeriesData: [
        { month: "JAN", value: 8500, target: 10000 },
        { month: "FEB", value: 9200, target: 10000 },
        { month: "MAR", value: 11000, target: 10000 },
        { month: "APR", value: 12500, target: 10000 },
        { month: "MAY", value: 9800, target: 10000 },
        { month: "JUN", value: 13600, target: 10000 },
        { month: "Sep", value: 9800, target: 10000 },
    ]

    Rectangle {
        anchors.fill: parent
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: contentColumn.height

        Column {
            id: contentColumn
            width: parent.width
            spacing: Theme.paddingLarge

            // Заголовок с иконкой
            PageHeader {
                title: qsTr("Financial Analytics")
                Icon {
                    source: "image://theme/icon-m-graph"
                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        margins: Theme.paddingLarge
                    }
                }
            }

            // Карточка с общей статистикой
            Rectangle {
                width: parent.width - 2*Theme.horizontalPageMargin
                x: Theme.horizontalPageMargin
                height: Theme.itemSizeExtraLarge*1.25
                radius: Theme.paddingMedium
                color: "#24224f"
                border.color: Theme.rgba(currentColor, 0.3)
                border.width: 1

                Row {
                    anchors.centerIn: parent
                    spacing: Theme.paddingLarge

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        Label {
                            text: qsTr("Total")
                            color: Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeExtraLarge
                        }
                        Label {
                            text: {
                                var total = 0;
                                for (var i = 0; i < timeSeriesData.length; i++) {
                                    total += timeSeriesData[i].value;
                                }
                                return (total/1000).toFixed(1) + "k ₽"
                            }
                            color: Theme.secondaryColor334
                            font {
                                pixelSize: Theme.fontSizeExtraLarge*1.25
                                family: Theme.fontFamilyHeading
                            }
                        }
                    }

                    Rectangle {
                        width: 1
                        height: Theme.itemSizeMedium
                        color: Theme.rgba(currentColor, 0.3)
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        Label {
                            text: qsTr("Average")
                            color: Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeExtraLarge
                        }
                        Label {
                            text: {
                                var avg = 0;
                                for (var i = 0; i < timeSeriesData.length; i++) {
                                    avg += timeSeriesData[i].value;
                                }
                                return (avg/timeSeriesData.length/1000).toFixed(1) + "k ₽"
                            }
                            color: "white"
                            font {
                                pixelSize: Theme.fontSizeExtraLarge*1.25
                                family: Theme.fontFamilyHeading
                            }
                        }
                    }
                }
            }

            // График с горизонтальным скроллом
            Item {
                width: parent.width
                height: 320  // Увеличил высоту для лучшего отображения
                clip: true

                SilicaFlickable {
                    id: chartFlickable
                    anchors.fill: parent
                    contentWidth: chartContainer.width
                    interactive: contentWidth > width

                    Item {
                        id: chartContainer
                        width: Math.max(chartFlickable.width, timeSeriesData.length * 140) // Увеличил минимальную ширину на точку
                        height: parent.height

                        // Линия цели
                        Canvas {
                            anchors.fill: parent
                            onPaint: {
                                var ctx = getContext("2d");
                                ctx.reset();

                                var firstTarget = timeSeriesData[0].target;
                                var y = height * 0.7; // Фиксированная позиция для цели

                                ctx.strokeStyle = Theme.rgba(Theme.secondaryColor, 0.5);
                                ctx.lineWidth = 1;
                                ctx.setLineDash([5, 3]);
                                ctx.beginPath();
                                ctx.moveTo(0, y);
                                ctx.lineTo(width, y);
                                ctx.stroke();

                                ctx.fillStyle = Theme.secondaryColor;
                                ctx.font = "bold " + (Theme.fontSizeSmall + 2) + "px " + Theme.fontFamily; // Увеличил шрифт
                                ctx.textAlign = "center";
                                ctx.fillText("TARGET: " + (firstTarget/1000) + "k", width - 120, y - 8); // Сдвинул подальше от края
                            }
                        }

                        // Основной график
                        Canvas {
                            id: chartCanvas
                            anchors {
                                fill: parent
                                margins: Theme.paddingLarge
                            }

                            onPaint: {
                                var ctx = getContext("2d");
                                ctx.reset();

                                if (timeSeriesData.length < 2) return;

                                // Рассчитываем масштаб
                                var maxValue = Math.max.apply(null, timeSeriesData.map(function(d) { return Math.max(d.value, d.target); }));
                                var xStep = Math.max(140, width / (timeSeriesData.length - 1)); // Увеличил шаг между точками

                                // Увеличим толщину линии графика
                                ctx.strokeStyle = currentColor;
                                ctx.lineWidth = 4; // Было 3
                                ctx.lineJoin = "round";
                                ctx.beginPath();

                                for (var i = 0; i < timeSeriesData.length; i++) {
                                    var x = i * xStep;
                                    var y = height - (timeSeriesData[i].value / maxValue * height);

                                    if (i === 0) {
                                        ctx.moveTo(x, y);
                                    } else {
                                        ctx.lineTo(x, y);
                                    }
                                }

                                ctx.stroke();

                                // Рисуем точки
                                ctx.fillStyle = currentColor;
                                for (var j = 0; j < timeSeriesData.length; j++) {
                                    x = j * xStep;
                                    y = height - (timeSeriesData[j].value / maxValue * height);

                                    // Эффект свечения - сделаем больше
                                    ctx.shadowColor = currentColor;
                                    ctx.shadowBlur = 10;
                                    ctx.beginPath();
                                    ctx.arc(x, y, 10, 0, Math.PI * 2); // Было 6
                                    ctx.fill();

                                    // Основная точка - увеличим размер
                                    ctx.shadowBlur = 0;
                                    ctx.beginPath();
                                    ctx.arc(x, y, 8, 0, Math.PI * 2); // Было 4
                                    ctx.fill();

                                    // Подписи месяцев - увеличим шрифт и отступ
                                    ctx.fillStyle = Theme.primaryColor;
                                    ctx.font = "bold " + (Theme.fontSizeMedium + 4) + "px " + Theme.fontFamily; // Увеличил шрифт
                                    ctx.textAlign = "center";
                                    ctx.fillText(timeSeriesData[j].month, x, height + 30); // Было +20

                                    // Подписи значений - увеличим шрифт и поднимем выше
                                    ctx.fillStyle = currentColor;
                                    ctx.font = "bold " + (Theme.fontSizeExtraLarge) + "px " + Theme.fontFamily;
                                    ctx.fillText((timeSeriesData[j].value/1000).toFixed(1) + "k", x, y - 20); // Было -10
                                }
                            }
                        }
                    }
                }
                HorizontalScrollDecorator {}
            }

            // Индикаторы прогресса
            Column {
                width: parent.width - 2*Theme.horizontalPageMargin
                x: Theme.horizontalPageMargin
                spacing: Theme.paddingMedium

                Repeater {
                    model: timeSeriesData.slice().reverse().slice(0, 3) // Последние 3 месяца

                    delegate: Column {
                        width: parent.width
                        spacing: Theme.paddingSmall

                        Label {
                            text: modelData.month
                            color: Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeSmall
                        }

                        ProgressBar {
                            width: parent.width
                            minimumValue: 0
                            maximumValue: modelData.target
                            value: modelData.value
                            label: value.toFixed(0) + " / " + maximumValue.toFixed(0) + " ₽"
                            valueText: (value/maximumValue*100).toFixed(0) + "%"
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        chartCanvas.requestPaint();
    }
}
