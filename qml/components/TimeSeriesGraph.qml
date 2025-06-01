import QtQuick 2.0
import Sailfish.Silica 1.0

Item {

    property var model: []
    property bool isExpense: true
    property color lineColor: isExpense ? Theme.errorColor : Theme.highlightColor
    property real maxValue: 0
    property real minValue: 0
    property int padding: Theme.paddingLarge

    onModelChanged: {
        calculateBounds();
        canvas.requestPaint();
    }

    Canvas {
        id: canvas
        anchors {
            fill: parent
            margins: padding
        }

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();

            if (model.length < 2)
                return;

            var width = canvas.width;
            var height = canvas.height;
            var xStep = width / (model.length - 1);

            ctx.strokeStyle = Theme.rgba(Theme.primaryColor, 0.1);
            ctx.lineWidth = 1;

            var gridLines = 5;

            for (var i = 0; i <= gridLines; i++) {
                var y = height - (i * height / gridLines);
                ctx.beginPath();
                ctx.moveTo(0, y);
                ctx.lineTo(width, y);
                ctx.stroke();

                ctx.fillStyle = Theme.primaryColor;
                ctx.font = '12px Sans-Serif';
                ctx.fillText(Math.round(minValue + (maxValue - minValue) * (1 - i / gridLines)), width + 5, y + 4);
            }

            ctx.strokeStyle = lineColor;
            ctx.lineWidth = 2;
            ctx.beginPath();

            for (var j = 0; j < model.length; j++) {
                var x = j * xStep;
                var valueY = height - ((model[j].value - minValue) / (maxValue - minValue) * height);

                if (j === 0) {
                    ctx.moveTo(x, valueY);
                } else {
                    ctx.lineTo(x, valueY);
                }

                ctx.fillStyle = lineColor;
                ctx.beginPath();
                ctx.arc(x, valueY, 4, 0, Math.PI * 2);
                ctx.fill();

                if (j % Math.max(1, Math.floor(model.length / 5)) === 0 || j === model.length - 1) {
                    ctx.fillStyle = Theme.primaryColor;
                    ctx.font = '10px Sans-Serif';
                    var dateText = model[j].date.toLocaleDateString(Qt.locale(), "MMM yy");
                    ctx.fillText(dateText, x - ctx.measureText(dateText).width / 2, height + 15);
                }
            }

            ctx.stroke();
        }
    }

    Rectangle {
        anchors {
            top: parent.top
            right: parent.right
            margins: Theme.paddingMedium
        }
        width: legendText.width + 2 * Theme.paddingSmall
        height: legendText.height + 2 * Theme.paddingSmall
        color: Theme.rgba(Theme.secondaryHighlightColor, 0.2)
        radius: Theme.paddingSmall

        Label {
            id: legendText
            anchors.centerIn: parent
            text: isExpense ? qsTr("Expenses") : qsTr("Income")
            color: lineColor
            font.pixelSize: Theme.fontSizeExtraSmall
        }
    }

    function calculateBounds() {
        if (model.length === 0)
            return;

        maxValue = model[0].value;
        minValue = model[0].value;

        for (var i = 1; i < model.length; i++) {
            maxValue = Math.max(maxValue, model[i].value);
            minValue = Math.min(minValue, model[i].value);
        }

        var range = maxValue - minValue;
        maxValue += range * 0.1;
        minValue = Math.max(0, minValue - range * 0.1);
    }
}
