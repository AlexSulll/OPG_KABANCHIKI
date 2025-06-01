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
    property bool isExpense: true
    property string selectedPeriod: "All"
    property var dateRange: []
    property var operationModel: null
    property string currentPeriod: "All"
    property int selectedSector: -1

    Models.DateFilterModel {
        id: dateModel
    }

    Rectangle {
        id: cardBackground
        anchors.fill: parent
        radius: Theme.paddingLarge * 1.5
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: "#24224f"
            }
            GradientStop {
                position: 1.0
                color: "#1a1a3a"
            }
        }

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
                        text: qsTr(dateLabel)
                        color: selectedPeriod === dateId ? Theme.highlightColor : Theme.secondaryColor
                        font.pixelSize: Theme.fontSizeExtraLarge
                        font.underline: selectedPeriod === dateId
                    }

                    onClicked: {
                        selectedPeriod = dateId;
                        operationModel.currentPeriod = selectedPeriod;
                        dateFilter.currentPeriod = selectedPeriod;
                        selectedSector = -1;

                        var filteredOps = operationModel.service.getFilteredCategories(mainpage.action, selectedPeriod);

                        operationModel.loadOperation(filteredOps);
                        operationModel.calculateTotalBalance();

                        isExpense = mainpage.action === 0;
                        sectorModel.calculateChartData(operationModel, mainpage.action);
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
                    var ctx = getContext("2d");
                    ctx.reset();
                    var centerX = width / 2;
                    var centerY = height / 2;
                    var radius = Math.min(width, height) * 0.35;
                    var lineWidth = radius * 0.75;

                    ctx.beginPath();
                    ctx.arc(centerX, centerY, radius, 0, Math.PI * 2, false);
                    ctx.lineWidth = lineWidth;
                    ctx.strokeStyle = isExpense ? Theme.rgba("#FF6384", 0.2) : Theme.rgba("#36A2EB", 0.2);
                    ctx.stroke();
                }
            }

            Canvas {
                id: sectorsCanvas
                anchors.fill: parent

                property var sectorAngles: []

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();
                    var centerX = width / 2;
                    var centerY = height / 2;
                    var radius = Math.min(width, height) * 0.35;
                    var lineWidth = radius * 0.55;
                    var startAngle = -Math.PI / 2;
                    var total = 0;
                    sectorAngles = [];

                    for (var i = 0; i < sectors.length; i++) {
                        if ((isExpense && sectors[i].isExpense) || (!isExpense && !sectors[i].isExpense)) {
                            total += sectors[i].value;
                        }
                    }

                    if (total <= 0) {
                        ctx.beginPath();
                        ctx.arc(centerX, centerY, radius, 0, Math.PI * 2, false);
                        ctx.lineWidth = lineWidth;
                        ctx.strokeStyle = Theme.rgba(Theme.secondaryColor, 0.2);
                        ctx.stroke();
                        return;
                    }

                    for (var j = 0; j < sectors.length; j++) {
                        var sector = sectors[j];

                        if ((isExpense && !sector.isExpense) || (!isExpense && sector.isExpense)) {
                            continue;
                        }

                        var angle = (sector.value / total) * Math.PI * 2;
                        var endAngle = startAngle + angle;

                        sectorAngles.push({
                            start: startAngle,
                            end: endAngle,
                            index: j,
                            radius: radius
                        });

                        var currentRadius = (selectedSector === j) ? radius * 1.1 : radius;
                        var currentLineWidth = (selectedSector === j) ? lineWidth * 1.1 : lineWidth;

                        ctx.beginPath();
                        ctx.arc(centerX, centerY, currentRadius, startAngle, endAngle, false);
                        ctx.lineWidth = currentLineWidth;
                        ctx.strokeStyle = sector.color || (isExpense ? "#FF6384" : "#36A2EB");
                        ctx.stroke();

                        startAngle = endAngle;
                    }
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        var centerX = width / 2;
                        var centerY = height / 2;
                        var clickX = mouse.x - centerX;
                        var clickY = mouse.y - centerY;
                        var distance = Math.sqrt(clickX * clickX + clickY * clickY);
                        var clickAngle = Math.atan2(clickY, clickX);
                        var clickedInsideSector = false;

                        if (clickAngle < 0)
                            clickAngle += 2 * Math.PI;

                        for (var i = 0; i < sectorsCanvas.sectorAngles.length; i++) {
                            var sector = sectorsCanvas.sectorAngles[i];

                            var sectorRadius = (selectedSector === sector.index) ? sector.radius * 1.1 : sector.radius;
                            var sectorLineWidth = (selectedSector === sector.index) ? sector.radius * 0.55 * 1.1 : sector.radius * 0.55;

                            var minRadius = Math.max(0, sectorRadius - sectorLineWidth / 2);
                            var maxRadius = sectorRadius + sectorLineWidth / 2;

                            if (distance >= minRadius && distance <= maxRadius) {
                                var startAngle = sector.start < 0 ? sector.start + 2 * Math.PI : sector.start;
                                var endAngle = sector.end < 0 ? sector.end + 2 * Math.PI : sector.end;

                                var angleInSector = false;

                                if (startAngle <= endAngle) {
                                    angleInSector = (clickAngle >= startAngle && clickAngle <= endAngle);
                                } else {
                                    angleInSector = (clickAngle >= startAngle || clickAngle <= endAngle);
                                }

                                if (angleInSector) {
                                    clickedInsideSector = true;

                                    if (selectedSector === sector.index) {
                                        selectedSector = -1;
                                    } else {
                                        selectedSector = sector.index;
                                    }

                                    sectorsCanvas.requestPaint();
                                    break;
                                }
                            }
                        }

                        if (!clickedInsideSector && selectedSector !== -1) {
                            selectedSector = -1;
                            sectorsCanvas.requestPaint();
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
                    text: qsTr(isExpense ? "Расходы" : "Доходы")
                    color: Theme.primaryColor
                    font.pixelSize: Theme.fontSizeSmall
                }

                Label {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    text: {
                        function formatMoney(value) {
                            var absValue = Math.abs(value);
                            var suffix = "";
                            var formattedValue = 0;

                            if (absValue >= 1000000000000) {
                                formattedValue = (value / 1000000000000).toFixed(1);
                                suffix = " трлн";
                            } else if (absValue >= 1000000000) {
                                formattedValue = (value / 1000000000).toFixed(1);
                                suffix = " млрд";
                            } else if (absValue >= 1000000) {
                                formattedValue = (value / 1000000).toFixed(1);
                                suffix = " млн";
                            } else {
                                return Number(value).toLocaleString(Qt.locale(), 'f', 2) + " ₽";
                            }

                            formattedValue = formattedValue.replace(".", ",").replace(",0", "");
                            return formattedValue + suffix + " ₽";
                        }

                        if (selectedSector >= 0 && selectedSector < sectors.length) {
                            return formatMoney(sectors[selectedSector].value);
                        } else {
                            var sum = 0;

                            for (var i = 0; i < sectors.length; i++) {
                                if ((isExpense && sectors[i].isExpense) || (!isExpense && !sectors[i].isExpense)) {
                                    sum += sectors[i].value;
                                }
                            }

                            return formatMoney(sum);
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
                            return sectors[selectedSector].name || "Категория";
                        } else {
                            var count = 0;

                            for (var i = 0; i < sectors.length; i++) {
                                if ((isExpense && sectors[i].isExpense) || (!isExpense && !sectors[i].isExpense)) {
                                    count++;
                                }
                            }

                            return count === 1 && sectors[0]["value"] === 0 ? "Нет категорий" : count + " категори" + (count === 1 ? "я" : (count >= 5 ? "й" : "и"));
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
        selectedSector = -1;
        backgroundRing.requestPaint();
        sectorsCanvas.requestPaint();
    }
}
